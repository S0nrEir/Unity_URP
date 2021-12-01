//雾效shader
Shader "ShaderBook/Chapter13/FogWithDepthTex" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_FogDensity("Fog Density",Float) = 1.0
		_FogColor("Fog Color",Color) = (1,1,1,1)
		_FogStart("Fog Start Height",Float) = 1.0
		_FogEnd("Fog End Height",Float) = 1.0
	}

	//基于后处理的全局雾效的关键是，根据深度纹理来重建每个像素点在世界空间下的位置
	//即构建出当前像素的NDC坐标，然后通过当前相机的视角*投影矩阵的逆矩阵来获得世界空间下的像素坐标
	//但这样需要在片元着色器中进行矩阵乘法，影响性能

	//另一种比较好的方法是，使用深度纹理
	//如何利用深度纹理重建像素点在世界下的坐标：
	//
	SubShader 
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		//由脚本传递近裁面四角的向量
		//插值后的像素向量
		float4x4 _FrustumConersRay;
		//主纹理
		sampler2D _MainTex;
		//纹素采样
		half4 _MainTex_TexelSize;
		//深度纹理
		sampler2D _CameraDepthTexture;
		//雾效浓度
		half _FogDensity;
		//雾效颜色
		fixed4 _FogColor;
		//雾效起始高度
		float _FogStart;
		//雾效结束高度
		float _FogEnd;

		struct v2f
		{
			float4 pos 			  : SV_POSITION;
			half2 uv 			  : TEXCOORD0;
			half2 uv_depth 		  : TEXCOORD1;
			float4 interpolateRay : TEXCOORD2;
		};

		int get_frustum_coner_index(half2 texcoord)
		{
			//unity中纹理坐标的(0,0)对应左下角，(1,1)对应右上角
			int idx = 0;
			//左下
			if(texcoord.x < 0.5 && texcoord.y < 0.5)
				idx = 0;
			//右下
			else if(texcoord.x > 0.5 && texcoord.y < 0.5)
				idx = 1;
			//右上
			else if(texcoord.x > 0.5 && texcoord.y > 0.5)
				idx = 2;
			//左上
			else
				idx = 3;

			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				idx = 3 - idx;
			#endif

			return idx;
		}

		//vertex:
		v2f fog_vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;

			//平台差异化处理
			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0)
				o.uv_depth.y = 1 - o.uv_depth.y;
			#endif

			int idx = get_frustum_coner_index(v.texcoord);
			//获取对应的射线向量
			o.interpolateRay = _FrustumConersRay[idx];

			return o;
		}

		//fragment
		fixed4 fog_frag(v2f i) : SV_Target
		{
			//重建像素在世界空间下的位置
			//对深度贴图采样，获取线性深度
			//LinearEyeDepth：视角空间下的线性深度值
			// float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
			float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
			//映射世界坐标
			float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolateRay;

			float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
			fogDensity = saturate(fogDensity * _FogDensity);

			//最终呈现颜色
			fixed4 finalColor = tex2D(_MainTex,i.uv); 
			finalColor.rgb = lerp(finalColor.rgb , _FogColor.rgb , fogDensity);
			return finalColor;
		}

		ENDCG

		Pass
		{	
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM

			#pragma vertex fog_vert
			#pragma fragment fog_frag

			ENDCG
		}
	}
	FallBack Off
}
