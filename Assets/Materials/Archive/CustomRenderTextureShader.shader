Shader "CustomRenderTexture/CustomRenderTextureShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("InputTex", 2D) = "white" {}
        _MousePosition("MousePosition", Vector) = (0.5,0.5,0,0)
        _CircleRadius("CircleRadius", Float) = 0.1
     }

     SubShader
     {
        Blend One Zero

        Pass
        {
            Name "CustomRenderTextureShader"

            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 3.0

            float4      _Color;
            sampler2D   _MainTex;
            float4      _MousePosition;
            float       _CircleRadius;

            float4 frag(v2f_customrendertexture IN) : SV_Target
            {
                float2 uv = IN.localTexcoord.xy;
                float4 color = _Color;
                float distanceToMouse = sqrt(pow((uv.x - _MousePosition.x) / 0.5625, 2) + pow(uv.y - _MousePosition.y, 2));
                if (distanceToMouse <= _CircleRadius)
                {
                    color = float4(1,0,0,1);
                }

                // TODO: Replace this by actual code!
                //uint2 p = uv.xy * 256;
                return color; //countbits(~(p.x & p.y) + 1) % 2 * float4(uv, 1, 1) * color;
            }
            ENDCG
        }
    }
}
