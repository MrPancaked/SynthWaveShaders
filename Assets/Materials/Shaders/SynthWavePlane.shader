Shader "Unlit/SynthWavePlane"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Heightmap ("Texture", 2D) = "black" {}
        _HeightScale ("HeightScale", Float) = 1
        _LineColor ("LineColor", Color) = (0,1,1,1)
        _LineWidth ("LineWidth", Float) = 0.01
        _LineFrequency ("LineFrequency", float) = 20
        _ScrollSpeed ("ScrollSpeed", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };
            
            float4 _LineColor;
            float _LineWidth;
            float _LineFrequency;
            float _ScrollSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 gridUV = i.uv * _LineFrequency;
                gridUV.y += _Time.y * _ScrollSpeed;
                float2 gridLine = abs(frac(gridUV - 0.5) - 0.5) / (fwidth(gridUV) * _LineWidth);
                float lineMask = 1.0 - min(min(gridLine.x, gridLine.y), 1.0);
                float smoothLine = smoothstep(0.0, 1.0, lineMask);

                fixed4 col = lerp(float4(0,0,0,1), _LineColor, smoothLine);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
