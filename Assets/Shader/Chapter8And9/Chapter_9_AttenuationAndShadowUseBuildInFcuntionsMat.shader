// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderBook/Chapter_9_AttenuationAndShadowUseBuildInFcuntionsMat"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        //BasePass中处理平行光
        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                //该xy坐标用于对阴影纹理采样
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //世界法线
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                //计算阴影纹理坐标
                //将顶点从模型空间变换到光源空间后，保存在_ShadowCoord
                TRANSFER_SHADOW(o);

                return o;
            }

            //逐像素的平行光
            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0,dot(worldNormal,worldLightDir));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

                //用_ShadowCoor对阴影纹理采样得到阴影信息
                fixed shadow = SHADOW_ATTENUATION(i);

                //平行光没有衰减系数
                //fixed atten = 1.0;

                //内置宏计算光照衰减和阴影放到atten
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                return fixed4(ambient + (diffuse + specular) * atten , 1.0);
                //return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);
            }
            ENDCG
        }//end BasePass

        //逐像素光源Additional Pass
        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            Blend One One

            CGPROGRAM
            //#pragma multi_compile_fwdadd
            #pragma multi_compile_fwdadd_fullshadows
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f 
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);

                //检查光源类型
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                //fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0,dot(worldNormal,worldLightDir));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

                // #ifdef USING_DIRECTIONAL_LIGHT
                //     fixed atten = 1.0;
                // #else
                //     float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
                //     fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                // #endif

                //内置宏计算光照衰减和阴影放到atten
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                return fixed4(diffuse + specular , 1.0);
                //return fixed4( (diffuse + specular) * atten, 1.0 );
            }
            ENDCG
         }//end pass
    }
    FallBack "Specular"
    //FallBack "Diffuse"
}
