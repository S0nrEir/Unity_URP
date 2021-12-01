Shader "ShaderBook/Chapter12/GaussianBlur" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize("BlurSize",Float) = 1.0//采样距离
	}

	SubShader 
	{
		CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		//计算纹理偏移量
		half4 _MainTex_TexelSize;
		float _BlurSize;

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};

		v2f vert_blur_vertical(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			half2 uv = v.texcoord;

			//在这里构建一个5x5的GaussianCore
			//GaussianCore不变的情况下，blurSize越大，模糊程度越高
			o.uv[0] = uv;
			o.uv[1] = uv + float2(0.0,_MainTex_TexelSize.y * 1.0) * _BlurSize;
			o.uv[2] = uv - float2(0.0,_MainTex_TexelSize.y * 1.0) * _BlurSize;
			o.uv[3] = uv + float2(0.0,_MainTex_TexelSize.y * 2.0) * _BlurSize;
			o.uv[4] = uv - float2(0.0,_MainTex_TexelSize.y * 2.0) * _BlurSize;

			return o;
		}

		v2f vert_blur_horizontal(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			half2 uv = v.texcoord;
			o.uv[0] = uv;
			o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
			o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
			o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;

			return o;
		}

		fixed4 frag_blur(v2f i) : SV_Target
		{
			//0.4026是中心值
			float weight[3] = {0.4026, 0.2442, 0.0545};
			//中心点乘以颜色和权重的结果
			//采样结果返回0到1
			fixed3 sum = tex2D(_MainTex,i.uv[0]).rgb * weight[0];

			//5x5的高斯核可以拆成两个大小为5的一维高斯核，由于权重的对称性，只需要记录三个高斯权重即可
			//取垂直or水平方向的四个相邻坐标采样点再乘以权重
			for(int it = 1; it < 3 ; it++)
			{
				sum += tex2D(_MainTex,i.uv[it * 2 - 1]).rgb * weight[it];
				sum += tex2D(_MainTex,i.uv[it * 2]).rgb * weight[it];
			}

			return fixed4(sum,1.0);
		}
		ENDCG

		//set render state
		ZTest Always
		Cull Off
		ZWrite Off

		Pass 
		{
			//decalera name of the pass
			NAME "GAUSSIAN_BLUR_VERTICAL"
			CGPROGRAM

			#pragma vertex vert_blur_vertical
			#pragma fragment frag_blur

			ENDCG

		} 

		Pass
		{
			NAME "GAUSSIAN_BLUR_HORIZONTAL"
			CGPROGRAM

			#pragma vertex vert_blur_horizontal
			#pragma fragment frag_blur

			ENDCG
		}
	}
	FallBack "Diffuse"
}
