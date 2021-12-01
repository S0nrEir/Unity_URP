// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
//基于噪点图的全局雾效
Shader "ShaderBook/Chapter15/FogWitNoise"
{
    Properties
    {
    	_MainTex("Main Tex",2D) = "white"{}
        //雾效浓度
        _FogDensity("Fog Density",Float) = 1.0
        //雾效颜色
        _FogColor("Fog Color",Color) = (1,1,1,1)
        //雾效起始高度
        _FogStart("Fog Start",Float) = 0.0
        _FogEnd("Fog End",Float) = 1.0
        //噪点图
        _NoiseTex("Noise Tex",2D) = "white"{}

        _FogXSpeed("Fox X Speed",Float) = 0.1
        _FogYSpeed("Fox Y Speed",Float) = 0.1
        //噪点系数
        _NoiseAmount("Noise Amount",Float) = 1.0
    }

    SubShader
    {
    	CGINCLUDE
    	#include "UnityCG.cginc"

    	float4x4 _FrustumCornersRay;

    	sampler2D _MainTex;
    	half4 	  _MainTex_TexelSize;
    	sampler2D _CameraDepthTexture;
    	half 	  _FogDensity;
    	fixed4 	  _FogColor;
    	float 	  _FogStart;
    	float 	  _FogEnd;
    	sampler2D _NoiseTex;
    	half	  _FogXSpeed;
    	half	  _FogYSpeed;
    	half	  _NoiseAmount;

		struct v2f
		{
			float4 pos 			  : SV_POSITION;
			half2 uv 			  : TEXCOORD0;
			half2 uv_depth 		  : TEXCOORD1;
			float4 interpolateRay : TEXCOORD2;
		};

		int get_frustum_corner_index(half2 texcoord)
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

            //DirectX平台差异化处理
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				idx = 3 - idx;
			#endif

			return idx;
		}

    	//vert
    	v2f fog_noise_vert(appdata_img v)
    	{
    		v2f o;
    		o.pos = UnityObjectToClipPos(v.vertex);

    		o.uv = v.texcoord;
    		o.uv_depth = v.texcoord;

    		#if UNITY_UV_STARTS_AT_TOP
    			if(_MainTex_TexelSize.y <0)
    				o.uv_depth.y = o.uv_depth.y;
    		#endif

    		int row = get_frustum_corner_index(v.texcoord);
    		o.interpolateRay = _FrustumCornersRay[row];

    		return o;
    	}

    	//frag
    	fixed4 fog_noise_frag(v2f i):SV_Target
    	{
    		//获取线性深度
    		float linear_depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
    		//当前像素点在世界空间的位置
    		float3 world_pos = _WorldSpaceCameraPos + linear_depth * i.interpolateRay.xyz;
    		float2 speed = _Time.y * float2(_FogXSpeed,_FogYSpeed);
    		//采样噪点图颜色
    		// float noise = (tex2D(_NoiseTex,i.uv + speed).r - 0.5) * _NoiseAmount;
            //减去0.5是为了让采样贴图不至于太亮（雾效太浓）
            float noise = (tex2D(_NoiseTex,i.uv + speed).b - 0.5) * _NoiseAmount;
        	float fog_density = (_FogEnd - world_pos.y) / (_FogEnd - _FogStart);
        	fog_density = saturate(fog_density * _FogDensity * (1 + noise));
        	fixed4 final_color = tex2D(_MainTex,i.uv);
        	final_color.rgb = lerp(final_color.rgb, _FogColor.rgb, fog_density);

            return final_color;

            //return fixed4(_FogColor.rgb, 1);
    	}

    	ENDCG

    	Pass
    	{    		
    		// ZTest Always
    		// ZWrite Off
    		// Cull Off

    		CGPROGRAM

    		#pragma vertex fog_noise_vert
    		#pragma fragment fog_noise_frag

    		ENDCG
    	}
    }
    FallBack Off
}
