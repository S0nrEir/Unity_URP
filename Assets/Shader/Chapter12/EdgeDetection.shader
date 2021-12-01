Shader "ShaderBook/Chapter12/EdgeDetection"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {} 
        _EdgeOnly("Edge Only",Float) = 1.0
        _EdgeColor("Edge Color",Color) =(0,0,0,1)
        _BackGroundColor("BackGround Color",Color) =(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            //开启深度检测但不写入，防止遮挡
            ZTest Always
            Cull Off
            ZWrite Off

            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles

            //#pragma target 3.0
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag_sobel

            sampler2D _MainTex;
            uniform half4 _MainTex_TexelSize;//纹素数据，访问该纹理每个纹素的大小
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackGroundColor;

            struct v2f 
            {
                float4 pos : SV_POSITION;
                half2 uv[9] : TEXCOORD0;
            };

            //计算sobel算子
            //void calc_sobel(half2[] uvs,half2 uv)
            //{
            //   //构建卷积核
            //   //对应sobel采样时需要的九个相邻纹理坐标区域
            //    uvs[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
            //    uvs[1] = uv + _MainTex_TexelSize.xy * half2(0,-1);
            //    uvs[2] = uv + _MainTex_TexelSize.xy * half2(1,-1);

            //    uvs[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
            //    uvs[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
            //    uvs[5] = uv + _MainTex_TexelSize.xy * half2(1,0);

            //    uvs[6] = uv + _MainTex_TexelSize.xy * half2(-1,1);
            //    uvs[7] = uv + _MainTex_TexelSize.xy * half2(0,1);
            //    uvs[8] = uv + _MainTex_TexelSize.xy * half2(1,1);
            //}


            fixed luminance(fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            half sobel(v2f i)
            {

                const half gx[9] = {-1,0,1,
                                    -2,0,2,
                                    -1,0,1};

                const half gy[9] = {-1,-2,-1,
                                    0,0,0,
                                    1,2,1};

                half texColor;
                half edgeX = 0;
                half edgeY = 0;
                for(int it = 0; it < 9 ; it++) 
                {
                    texColor = luminance(tex2D(_MainTex,i.uv[it]));
                    edgeX += texColor * gx[it];
                    edgeY += texColor * gy[it];
                }

                half edge = 1 - abs(edgeX) - abs(edgeY);
                return edge;
            }



            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //calc_sobel(o.uv, v.texcoord);

                half2 uv = v.texcoord;//模型空间下的纹理坐标
                // 构建卷积核
                // 对应sobel采样时需要的九个相邻纹理坐标区域
                 o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
                 o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,-1);
                 o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,-1);

                 o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
                 o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
                 o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1,0);

                 o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,1);
                 o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0,1);
                 o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1,1);

                return o;
            }

            fixed4 frag_sobel(v2f i) : SV_Target
            {
                //计算当前像素梯度值
                half edge = sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackGroundColor,edge);
                return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly); 
            }

            ENDCG
        } 
    }
    FallBack Off
}
