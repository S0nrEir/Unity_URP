Shader "ShaderBook/Chapter13/MotionBlurWithDepthTexture" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}

		//模糊图像使用的大小
		_BlurSize("BlurSize",Float) = 1.0
	}

	SubShader 
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		//properties:
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		//深度纹理
		sampler2D _CameraDepthTexture;
		//当前帧的投影逆矩阵
		float4x4 _CurrViewProjectionInverseMTX;
		//前一帧的投影矩阵	
		float4x4 _PreviousViewProjectionMTX;
		half _BlurSize;

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};

		//vertext:
		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;

			o.uv_depth = v.texcoord;

			//对于DX平台，需要处理平台差异导致的图像反转问题，在这里进行差异化处理
			//这样即使在DX上开启了Anti-Aliasing，也可以得到正确的图像
			#if UNITY_UV_STARTS_AT_TOP
				o.uv_depth.y = 1 - o.uv_depth.y;
			#endif

			return o;
		}

		//fragment
		fixed4 frag(v2f i) : SV_Target
		{
			//对深度纹理进行采样，获取深度值
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth);

			//构建像素的NDC坐标H，将顶点着色器带过来的顶点坐标（已经转换到裁剪空间），转换到NDC空间
			float4 H = float4(i.uv.x * 2 - 1,i.uv.y * 2 - 1,d * 2 - 1, 1);
			//之后通过乘以逆投影矩阵来得到该像素对应的世界坐标
			float4 D = mul(_CurrViewProjectionInverseMTX,H);
			//这里其实就是透视除法
			float4 worldPos = D/D.w;
			
			float4 currPos = H;
			float4 prevPos = mul(_PreviousViewProjectionMTX,worldPos);
			prevPos /= prevPos.w;
			float2 velocity = (currPos.xy - prevPos.xy) / 2.0f;
			float2 uv = i.uv;
			float4 c = tex2D(_MainTex,uv);
			uv += velocity * _BlurSize;

			for(int it = 1;it < 3 ;it++,uv+=velocity * _BlurSize)
			{
				float4 currColor = tex2D(_MainTex,uv);
				c += currColor;
			}

			c/=3;

			return fixed4(c.rgb,1.0);
		}

		ENDCG

		Pass
		{
			CGPROGRAM

			#pragma vertex  vert
			#pragma fragment frag

			ENDCG
		}
	}
	FallBack Off
}
