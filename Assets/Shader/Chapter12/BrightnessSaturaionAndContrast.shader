Shader "ShaderBook/Chapter12/BrightnessSaturaionAndContrast"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white"{}
        _Brightness("Brightness",Float) = 1
        _Saturation("Saturation",Float) = 1
        _Contrast("Contrast",Float) = 1
    }

    SubShader
    {
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off

            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };

            //appdata_img类型只包含了图像处理时必须的顶点坐标和纹理坐标
            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }


            //在片元着色器中调整亮度，饱和度和对比度
            fixed4 frag(v2f i):SV_Target
            {
                fixed4 renderTex = tex2D(_MainTex,i.uv);
                //亮度
                fixed3 finalColor = renderTex.rgb * _Brightness;

                //饱和度
                //计算该像素对应的亮度值
                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 luminanceColor = fixed3(luminance,luminance,luminance);
                finalColor = lerp(luminanceColor,finalColor,_Saturation);

                //对比度
                fixed3 avgColor = fixed3(0.5,0.5,0.5);
                finalColor = lerp(avgColor,finalColor,_Contrast);

                return fixed4(finalColor,renderTex.a);
            }
            ENDCG
        }
    }
    FallBack Off
}
