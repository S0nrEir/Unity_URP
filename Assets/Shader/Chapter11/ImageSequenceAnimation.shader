// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderBook/Chapter11/ImageSequenceAnimation"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Image Sequence", 2D) = "white" {}
        _HorizontalAmount ("Horizontal Amount", Float) = 4
        _VerticalAmount ("Vertical Amount", Float) = 4
        //动画速度
        _Speed("Speed",Range(1,100)) = 50
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"                
            }           

            //考虑到序列帧对象通常包含了透明通道，关闭深度写入
            //ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            //#pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag 
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0; 
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex); 

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float time = floor(_Time.y * _Speed) % (_HorizontalAmount * _VerticalAmount);
                //float time = _Time.y * _Speed;
                float row = floor(time / _HorizontalAmount);
                float col = time - row * _HorizontalAmount;

                //采样坐标
                // half2 uv = float2(i.uv.x / _HorizontalAmount,i.uv.y / _VerticalAmount);
                // uv.x += col / _HorizontalAmount;
                // uv.y -= row / _VerticalAmount;
                //这里要注意，uv坐标的范围是（0,0）至(1,1)，贴图MainTex被设置为了Repeat模式
                half2 uv = i.uv + half2(col,-row);
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount; 

                fixed4 c = tex2D(_MainTex,uv);
                //fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *= _Color;

                return c;
            }

            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
