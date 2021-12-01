// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderBook/Chapter8_AlphaBlendZWrite"
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
		}

		//该Pass只写入深度信息，为了剔除模型中被自身遮挡的片元
		Pass
		{
			ZWrite On
			ColorMask 0//开启颜色通道的写入掩码，ColorMask RGB | A | 0 | any other RGBA Color
		}
		Pass
		{
			Tags
			{ "LightMode"="ForwardBase" }

			ZWrite Off
			// ZTest Greater
			Blend SrcAlpha OneMinusSrcAlpha//混合模式

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

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
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex,i.uv);
				
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

				//alpha blend
				return fixed4(ambient + diffuse,  texColor.a * _AlphaScale);
			}

			ENDCG
		}

	}
	FallBack "Diffuse"
}
