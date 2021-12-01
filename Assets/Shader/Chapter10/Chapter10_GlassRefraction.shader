// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderBook/Chapter10/GlassRefraction"
{
    Properties
    {
        //主纹理
        _MainTex("Main Tex",2D) = "white"{}
        //模拟毛玻璃的表面法线
        _NormalMap("Normal Map",2D) = "bump"{}
        //CubeMap处理折射和反射
        _CubeMap("Cube Map",Cube) = "_SkyBox"{}
        //折射程度
        _Distortion("Distortion",Range(1,50)) = 10
        //折射系数
        _RefractAmount("Refract Amount",Range(0.0 , 1.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        //抓取屏幕图像
        GrabPass{"_RefractionTex"}

        Pass
        {
            Tags{"LightMode"="ForwardAdd"}

            CGPROGRAM

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            samplerCUBE _CubeMap;

            float _Distortion;
            fixed _RefractAmount;

            sampler2D _RefractionTex;
            //纹理纹素大小
            float4 _RefractionTex_TexelSize;


            struct a2v
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float4 tangent  : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos    : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv     : TEXCOORD1;

                //使用3x4来构建TBN变换矩阵
                float4 TtoW0  : TEXCOORD2;
                float4 TtoW1  : TEXCOORD3;
                float4 TtoW2  : TEXCOORD4; 
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);//视口空间坐标变换到屏幕坐标

                o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_NormalMap);


                float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                //计算世界空间下切线 副切线 法线的方向
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBiNormal = cross(worldNormal,worldTangent) * v.tangent.w;

                //按列拜访得到切线空间到世界空间的变换矩阵
                //该变换矩阵就是顶点的切线 副切线 法线在世界空间下的表示
                o.TtoW0 = float4(worldTangent.x,worldBiNormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBiNormal.y,worldNormal.y,worldPos.y);
                o.TtoW2 = float4(worldTangent.z,worldBiNormal.z,worldNormal.z,worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                //切线空间法线图采样
                fixed3 bump = UnpackNormal(tex2D(_NormalMap,i.uv.zw));
                //计算偏移，变换法线方向模拟折射
                // fixed2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                fixed2 offset = bump.xy  * _Distortion;
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
                //毛玻璃反射颜色
                //做透视除法得到真正的屏幕坐标
                fixed3 refrCol = tex2D(_RefractionTex,i.scrPos.xy / i.scrPos.w).rgb;
                //法线从切线空间变换到世界空间，计算折射
                bump = normalize(half3(dot(i.TtoW0.xyz, bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2,bump)));
                fixed3 reflDir = reflect(-worldViewDir,bump);
                fixed4 texColor = tex2D(_MainTex,i.uv.xy);
                fixed3 refCol = texCUBE(_CubeMap,reflDir).rgb * texColor.rgb;

                #ifdef POINT
                    float3 lightCoord = mul(unity_WorldToLight,float4(worldPos,1)).xyz;
                    fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                #else
                    fixed atten = 1.0;
                #endif
                // #ifdef USING_DIRECTIONAL_LIGHT
                //     fixed atten = 1.0;
                // #else
                //     float3 lightCoord = mul(unity_WorldToLight,float4(worldPos,1)).xyz;
                //     fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                // #endif


                fixed3 color = refCol * (1 - _RefractAmount) + refrCol * _RefractAmount;

                // fixed3 color = (refCol * atten) * (1 - _RefractAmount) + refrCol * _RefractAmount;

                return fixed4(color * atten,1);
            }
            ENDCG
        } 

    }
    FallBack "Diffuse"
}
