Shader "Unlit/PalmTree"
{
    Properties
    {
        _AmbientLightStrength ("Ambient Light Strength", Float) = 0.01
        _RimLightStrength ("Rimlight Strength", Float) = 0.5
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
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 worldSpacePosition : TEXCOORD2;
                float3 normal : TEXCOORD1;
            };
            
            float _AmbientLightStrength;
            float _RimLightStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldSpacePosition = mul(UNITY_MATRIX_M, v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                
                float3 lightDirection = -normalize(_WorldSpaceLightPos0.xyz);
                float3 cameraDirection = normalize(_WorldSpaceCameraPos - i.worldSpacePosition.xyz);
                float3 normal = normalize(i.normal);
                float diffuseLight =  saturate(dot(normal, -lightDirection));
                float3 reflectionVector = lightDirection - 2 * dot(lightDirection, normal) * normal;
                float specularReflectionLight = saturate(dot(cameraDirection, reflectionVector));
                float rimLight = length(cross(cameraDirection, normal));
                fixed4 col = _AmbientLightStrength * float4(0,1,1,1) + diffuseLight * _LightColor0 + pow(specularReflectionLight, 16) * _LightColor0 + pow(rimLight,16)* _RimLightStrength * _LightColor0;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
