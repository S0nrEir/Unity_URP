// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//消融效果
Shader "ShaderBook/Chapter15/Dissovle"
{
    Properties
    {
        //消融程度
        _BurnAmount("Burn Amoung",Range(0.0,1.0)) = 0.0
        //消融时的线宽
        _LineWidth("Burn Line Width",Range(0.0,0.2)) = 0.1
        //材质贴图
        _MainTex("Main Tex",2D) = "white"{}
        //法线贴图
        _BumpMap("Bump Map",2D) = "white"{}
        //火焰边缘的两种颜色
        _BurnFirstColor("Burn First Color",Color)=(1,0,0,0)
        _BurnSecondColor("Burn Second Color",Color) = (1,0,0,0)
        //消融贴图，噪点图
        _BurnMap("Burn Map",2D) = "white"{}
    }

    SubShader
    {
        //dissolve
        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            Cull Off

            CGPROGRAM

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase
            #pragma vertex vert_dissovle
            #pragma fragment frag_dissovle

            fixed _BurnAmount;
            fixed _LineWidth;
            sampler2D _MainTex;
            sampler2D _BumpMap;
            fixed4 _BurnFirstColor;
            fixed4 _BurnSecondColor;
            sampler2D _BurnMap;

            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            float4 _BurnMap_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos       : SV_POSITION;
                float2 uvMainTex : TEXCOORD0;
                float2 uvBumpMap : TEXCOORD1;
                float2 uvBurnMap : TEXCOORD2;
                float3 lightDir  : TEXCOORD3;
                float3 worldPos  : TEXCOORD4;
                SHADOW_COORDS(5)
            };

            v2f vert_dissovle(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uvMainTex = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.texcoord,_BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord,_BurnMap);
                
                TANGENT_SPACE_ROTATION;

                //将光源方向从模型空间变到切线空间
                o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag_dissovle(v2f i) : SV_Target
            {
                //采样然后剔除，越红的地方消融越晚
                fixed3 burn_color = tex2D(_BurnMap,i.uvBurnMap);
                fixed mix_factor = burn_color.r - _BurnAmount;
                clip(mix_factor);
                // clip(tex2D(_BurnMap, i.uvBurnMap).r - _BurnAmount);

                //切线空间下的光照方向
                float3 tangent_light_direction = normalize(i.lightDir);
                //切线空间下的法
                fixed3 tangent_normal = UnpackNormal(tex2D(_BumpMap,i.uvBumpMap));

                //正常着色
                fixed3 albedo = tex2D(_MainTex,i.uvMainTex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                //采样为0则直接是黑色，代表模型内部和背光面
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangent_normal,tangent_light_direction));
                //fixed3 diffuse = _LightColor0.rgb * albedo;

                //模拟消融颜色的变化，用t做混合系数
                fixed t = 1 - smoothstep(0.0, _LineWidth, mix_factor);
                fixed3 real_burn_color = lerp(_BurnFirstColor, _BurnSecondColor, t);
                real_burn_color = pow(real_burn_color,5);
                //real_burn_color*= 2;
                // real_burn_color = real_burn_color * real_burn_color;
                // real_burn_color = real_burn_color * real_burn_color;
                // real_burn_color = real_burn_color * real_burn_color;
                // real_burn_color = real_burn_color * real_burn_color;
                // real_burn_color = real_burn_color * real_burn_color;

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed3 final_color = lerp(ambient + diffuse * atten, real_burn_color, t * step(0.0001,_BurnAmount));

                return fixed4(final_color, 1);
            }

            ENDCG
        }

        //shadow caster
        Pass
        {
            Tags{"LightMode" = "ShadowCaster"}

            //Cull Front

            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma vertex shadow_vert
            #pragma fragment shadow_frag
            #pragma multi_compile_shadowcaster

            fixed _BurnAmount;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;

            struct v2f
            {
                V2F_SHADOW_CASTER;
                float2 uvBurnMap : TEXCOORD1;
            };

            v2f shadow_vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

                return o;
            }

            fixed4 shadow_frag(v2f i) : SV_Target
            {
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                clip(burn.r - _BurnAmount);

                //把片元着色器的结果投射到深度图中
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }

    }
    FallBack "Diffuse"
}
