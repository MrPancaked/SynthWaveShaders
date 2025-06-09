Shader "Unlit/WireFrameShader"
{
    Properties
    {
        _WireframeColor ("Wireframe Color", Color) = (0,1,1,1)
        _WireframeWidth ("Wireframe Thickness", Float) = 0.05
        _WireframeAliasing ("Wireframe Aliasing", Float) = 0.05
        _HeightMap ("Heightmap Texture", 2D) = "black" {}
        _HeightScale ("Height Scaling", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
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

            struct g2f
            {
                float4 pos : SV_POSITION;
                float3 barycentric : TEXCOORD0;
            };
            
            sampler2D _HeightMap;
            float4 _HeightMap_ST;
            float4 _WireframeColor;
            float _WireframeWidth;
            float _WireframeAliasing;
            float _HeightScale;

            v2f vert (appdata v)
            {
                v2f o;
                float4 uvHeightmap = float4(v.uv, 0, 0);
                float vertHeigt = tex2Dlod(_HeightMap, uvHeightmap).x * _HeightScale;
                v.vertex.y += vertHeigt;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _HeightMap);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2f IN[3], inout TriangleStream<g2f> triStream)
            {
                g2f o;
                o.pos = IN[0].vertex;
                o.barycentric = float3(1,0,0);
                triStream.Append(o);
                o.pos = IN[1].vertex;
                o.barycentric = float3(0,1,0);
                triStream.Append(o);
                o.pos = IN[2].vertex;
                o.barycentric = float3(0,0,1);
                triStream.Append(o);
            }

            fixed4 frag (g2f i) : SV_Target
            {
                float3 unitWidth = fwidth(i.barycentric);
                float3 aliased = smoothstep(float3(0,0,0), unitWidth * _WireframeAliasing, i.barycentric);
                //float3 closestToEdge = step(unitWidth * _WireframeWidth, i.barycentric);
                //float alpha = 1 - min(closestToEdge.x, min(closestToEdge.y, closestToEdge.z));
                float aliasedAlpha = 1 - min(aliased.x, min(aliased.y, aliased.z));
                return fixed4(aliasedAlpha * _WireframeColor.xyz, 1);
            }
            ENDCG
        }
    }
}
