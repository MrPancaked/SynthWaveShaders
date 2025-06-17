Shader "Unlit/SunShader"
{
    Properties
    {
        _MainTex ("MainTexture", 2D) = "black" {}
        _SunRadius ("SunRadius", float) = 0.5
        _SunColor1 ("SunColor1", Color) = (1,1,0,1)
        _SunColor2 ("SunColor2", Color) = (1,0,1,1)
        _LineFrequency ("LineFrequency", float) = 6
        _LineThickness ("LineThickness", float) = 0.05
        _LineSpeed ("LineSpeed", float) = 0.1
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
            float4 _MainTex_ST;
            float _SunRadius;
            float4 _SunColor1;
            float4 _SunColor2;
            float _LineFrequency;
            float _LineThickness;
            float _LineSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
                float4 origin = float4(0,0,0,1);
                float4 world_origin = mul(UNITY_MATRIX_M, origin);
                float4 view_origin = mul(UNITY_MATRIX_V, world_origin);
                float4 world_to_view_translation = view_origin - world_origin;

                float4 world_pos = mul(UNITY_MATRIX_M, v.vertex);
                float4 view_pos = world_pos + world_to_view_translation;
                float4 clip_pos = mul(UNITY_MATRIX_P, view_pos);

                o.vertex = clip_pos;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 black = float4(0,0,0,0);
                float4 col = black;
                float distanceToCentre = sqrt(pow(i.uv.x - 0.5, 2) + pow(i.uv.y - 0.5, 2));
                
                if (pow(sin((i.uv.y + _Time.y * _LineSpeed) * _LineFrequency * UNITY_PI), 2) <= pow((-i.uv.y + 1), _LineThickness) && i.uv.y < 0.6)
                {
                    discard;
                }
                
                if (distanceToCentre <= _SunRadius)
                {
                    col = _SunColor1 * i.uv.y + _SunColor2 * (1 - i.uv.y); //linear interpolate between colors
                }
                
                if (col.w <= 0.1)
                {
                    discard;
                }

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;
            }
            ENDCG
        }
    }
}
