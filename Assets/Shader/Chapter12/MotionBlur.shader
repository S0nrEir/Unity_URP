Shader "ShaderBook/Chapter12/MotionBlur" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		//运动模糊混合系数
		_BlurAmount("BlurAmount",Float) = 1.0
	}

	SubShader 
	{
		CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		//计算纹理偏移量
		// half4 _MainTex_TexelSize;
		fixed _BlurAmount;

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};

		//顶点着色器
		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;

			return o;
		}

		//使用两个片元着色器，一个更新rgb部分，一个更新alpha
		//使用blurAmoung作为透明度，这是为了在后续混合时可以使用他的透明通道进行混合
		fixed4 frag_rgb(v2f i) : SV_Target
		{
			return fixed4(tex2D(_MainTex , i.uv).rgb,_BlurAmount);
		}

		fixed4 frag_alpha(v2f i):SV_Target
		{
			return tex2D(_MainTex , i.uv);
		}

		ENDCG

		ZTest Always
		Cull Off
		Zwrite Off

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB//写入RGB

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag_rgb

			ENDCG
		}

		Pass
		{
			Blend One Zero
			ColorMask A//写入alpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag_alpha

			ENDCG
		}
	}
	FallBack Off
}
