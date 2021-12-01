//基于深度纹理和法线的3D边缘检测
Shader "ShaderBook/Chapter13/EdgeDetectNormalAndDepth" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgesOnly("Edges Only",Float) = 1.0
		_EdgeColor("Edge Color",Color) = (0,0,0,1)
		_BackGroundColor("BackGround Color",Color) = (1,1,1,1)
		_SampleDistance("SampleDistance",Float) = 1.0
		_Sensitivity("Sensitivity",Vector) = (1,1,1,1)
	}

	SubShader 
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		//properties:
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;

		fixed _EdgesOnly;
		fixed4 _EdgeColor;
		fixed4 _BackGroundColor;
		float _SampleDistance;
		half4 _Sensitivity;
		sampler2D _CameraDepthNormalsTexture;

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv[5] : TEXCOORD0;
		};

		//vertext:
		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.texcoord;
			//0存放的是纹理本身的uv坐标
			o.uv[0] = uv;

			//平台差异化处理
			#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0)
					uv.y = 1 - uv.y;
			#endif

			//剩下四组坐标存储了使用roberts算子时需要采样的纹理坐标，并且用distance控制采样距离
			o.uv[1] = uv + _MainTex_TexelSize.xy * half2(1,1) * _SampleDistance;
			o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1,-1) * _SampleDistance;
			o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,1) * _SampleDistance;
			o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1,-1) * _SampleDistance;

			return o;
		}

		//检查当前uv坐标点是否存在一条边缘
		//边缘检测为真，返回0，否则返回1
		half is_uv_contains_edge(half4 center,half4 sample)
		{
			//首先得到两个采样点的深度和法线
			//在这里并不需要解码获得真正的法线信息
			half2 center_normal = center.xy;
			float center_depth = DecodeFloatRG(center.zw);

			half2 sample_normal = sample.xy;
			float sample_depth = DecodeFloatRG(sample.zw);

			//获取法线差值
			half2 diff_normal = abs(center_normal - sample_normal) * _Sensitivity.x;
			int is_same_normal = (diff_normal.x + diff_normal.y) < 0.1;

			//获取深度差值
			float diff_depth = abs(center_depth - sample_depth) * _Sensitivity.y;
			int is_same_depth = diff_depth < 0.1 * center_depth;

			return is_same_normal * is_same_depth ? 1.0 : 0.0;
		}

		//fragment
		fixed4 frag(v2f i) : SV_Target
		{
			//左上右上左下右下
			//采样四个相邻纹理坐标的深度和法线
			half4 sample_1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);//1,1
			half4 sample_2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);//-1,-1
			half4 sample_3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);//-1,1
			half4 sample_4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);//1,-1

			//默认边缘深度
			half edge = 1.0;

			//右上和左下
			edge *= is_uv_contains_edge(sample_1,sample_2);
			//左上和右下
			edge *= is_uv_contains_edge(sample_3,sample_4);

			//插值返回边缘颜色或采样颜色
			// fixed4 with_edge_color = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
			// fixed4 only_edge_color = lerp(_EdgeColor, _BackGroundColor, edge);
			// return lerp(with_edge_color, only_edge_color, _EdgesOnly); 

			//以下是不包含背景色的版本
			fixed4 with_edge_color = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
			return with_edge_color;
		}

		ENDCG

		Pass
		{
			ZTest Always
			Cull Off
			Zwrite Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	}
	FallBack Off
}
