Shader "Unlit/SynthWaveMesh"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Heightmap ("Texture", 2D) = "black" {}
        _HeightScale ("HeightScale", Float) = 1
        _LineColor ("LineColor", Color) = (0,1,1,1)
        _LineWidth ("LineWidth", Float) = 0.01
        _LineFrequency ("LineFrequency", float) = 20
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

            sampler2D _MainTex;
            sampler2D _Heightmap;
            float4 _MainTex_ST;
            float _HeightScale;
            float4 _LineColor;
            float _LineWidth;
            float _LineFrequency;

            v2f vert (appdata v)
            {
                v2f o;
                float4 uvHeightmap = float4(v.uv, 0, 0);
                float vertHeigt = tex2Dlod(_Heightmap, uvHeightmap).x * _HeightScale;
                v.vertex.y += vertHeigt;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                float lineInterval = 1/_LineFrequency;
                float halfLineWidth = _LineWidth / 2;
                float Xmod = fmod(i.uv.x, lineInterval);
                float Ymod = fmod(i.uv.y, lineInterval);
                if ((Xmod >= lineInterval - halfLineWidth || Xmod <=  halfLineWidth) ||
                    (Ymod >= lineInterval - halfLineWidth || Ymod <=  halfLineWidth))
                {
                    col = _LineColor;
                }
                else
                {
                    col = float4(0,0,0,1);
                    //col = tex2D(_MainTex, i.uv);
                }
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
