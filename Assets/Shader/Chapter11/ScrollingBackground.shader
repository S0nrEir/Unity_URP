// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderBook/Chapter11/ScrollingBackground"
{
    Properties
    {
        _MainTex("Base Layer",2D) = "white"{}
        _DetailTex("2nd Layer",2D) = "white"{}
        _BaseSpeed("Base Speed",Float) = 1.0
        _DetailSpeed("2nd Speed",Float) = 1.0

        //控制纹理整体亮度
        _Multipier("Multipier",Float) = 1.0
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
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            //#pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag 
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _DetailTex;
            fixed4 _DetailTex_ST;
            float _BaseSpeed;
            float _DetailSpeed;
            float _Multipier;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0; 
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv  : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //两套坐标分别保存前景和背景的采样点
                //frac函数返回标量或每个向量中各分量的小数部分
                //0.0:y轴不偏移+
                o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex) + frac(float2(_BaseSpeed,0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_DetailTex) + frac(float2(_DetailSpeed,0.0) * _Time.y);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex,i.uv.zw);

                // fixed4 c = lerp(firstLayer,secondLayer,0);
                fixed4 c = lerp(firstLayer,secondLayer,secondLayer.a);
                //fixed4 c = firstLayer + secondLayer;
                c.rgb *= _Multipier;

                return c;
            }

            ENDCG
        }
    }
    FallBack "VertexLit"
}
