// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/PalmTree"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColor ("Light color", Color) = (1,0,1,1)
        _LightRange ("Light Range", int) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

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
            float4 _LightColor;
            int _LightRange;

            v2f vert (appdata v)
            {
                v2f o;
                float4 origin = float4(0,v.vertex.y,0,1);
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
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                if (col.w != 0)
                {
                    for (int j = 0; j < 10; j++)
                    {
                        if (tex2D(_MainTex, i.uv + float2(j * 0.002,j * 0.001)).w == 0)
                        {
                            float LightAmount = smoothstep(0, _LightRange, j);
                            col = fixed4((1 - LightAmount) * _LightColor.rgb, 1);
                            break;
                        }
                    }
                }
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
