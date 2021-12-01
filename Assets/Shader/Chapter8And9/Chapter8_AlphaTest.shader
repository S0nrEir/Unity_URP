// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderBook/Chapter8_AlphaTest"
{
	Properties
	{
		_Color("Main Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_Cutoff("Alpha _Cutoff",Range(1,0)) = 0.5 //透明度测试阈值
	}

	SubShader
	{
		Tags
		{
			"Queue" = "AlphaTest"//2450
			"IgnoreProjector" = "True"//不受到投影器的影响
			"RenderType"="TransparentCutout"
			//转到URP后，所有的sub tag中都要像下面这样指定URP渲染
			"RenderPipeline" = "UniversalPipeline"
		}

		Pass
		{
			Tags
			{
				//LightMode也要改变
				//UniversalForward：前向渲染物件之用
				//ShadowCaster： 投射阴影之用
				//DepthOnly：只用来产生深度图
				//Mata：来用烘焙光照图之用
				//Universal2D ：做2D游戏用的，用来替代前向渲染
				//UniversalGBuffer ： 貌似与延迟渲染相关（开发中）
				"LightMode" = "UniversalForward"
				"RenderPipeline" = "UniversalPipeline"
			}

			//CGPROGRAM 也要转变为HLSLINCLUDE
			//CGPROGRAM
			//#include "Lighting.cginc"
			//URP中放弃了XXX.cginc，取而代之的是下面的方式
			HLSLINCLUDE
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
			//Core	Unity.cginc	Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl
			//Light	AutoLight.cginc	Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl
			//Shadow	AutoLight.cginc	Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl
			//其他还有
			//Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl
			//Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl
			//Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl
			//Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl
			//Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl
			//Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl
			//Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTextue.hlsl

			half4 _Color; 
			//sampler2D _MainTex;
			float4 _MainTex_ST;
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			half _Cutoff;

			ENDHLSL

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			struct a2v
			{
				float4 vertex   : POSITION;
				float3 normal   : NORMAL;
				float4 texcoord :TEXCOORD0;
			};

			struct v2f
			{
				float4 pos 		   : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos	   : TEXCOORD1;
				float2 uv 	 	   :TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				//o.pos = UnityObjectToClipPos(v.vertex);
				//o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				//o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				//模型空间变换到裁剪空间（SpaceTransforms.hlsl）
				o.pos = TransformObjectToHClip(v.vertex);
				
				//获取世界空间下的法线方向
				o.worldNormal = TransformObjectToWorldNormal(v.normal.xyz, true);
				//o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//获取世界空间下的模型坐标位置
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				//对贴图进行采样
				half4 texColor = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
				//half4 texColor = tex2D(_MainTex,i.uv);
				//alpha test
				clip(texColor.a - _Cutoff);

				// if(texColor.a - _Cutoff < 0.0)
				// 	discard;

				half3 worldNormal = normalize(i.worldNormal);
				//世界光源方向
				half3 worldLightDir = normalize(_MainLightPosition.xyz - i.worldPos);
				//half3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				half3 albedo = texColor.rgb * _Color.rgb;

				//环境光
				half3 ambient = half3(unity_SHAr.w,unity_SHAg.w,unity_SHAb.w) * albedo;
				//half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//主光源(_MainLightColor)
				half3 diffuse = _MainLightColor.rgb * albedo * max(0,dot(worldNormal,worldLightDir));
				//half3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));
				return half4 ( ambient + diffuse, 1.0);
			}
			ENDHLSL
		}

	}
	//FallBack "Transparent/Cutout/VertexLit"
}
