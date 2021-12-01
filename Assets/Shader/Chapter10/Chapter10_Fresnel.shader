// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderBook/Chapter10_Fresnel"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        //反射率
        _FresnelScale("Fresnel Scale",Range(0,1)) = 0.5
        _Cubemap("Reflection Cubemap",Cube) = "_Skybox"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
//        LOD 100


        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;
            float _FresnelScale;
            samplerCUBE _Cubemap;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos                : SV_POSITION;
                fixed3 worldNormal        : TEXCOORD0;
                float3 worldPos           : TEXCOORD1;
                fixed3 worldViewDirection : TEXCOORD2;//cubeMap采样方向
                fixed3 worldRefl          : TEXCOORD3;//反射方向
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldViewDirection = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefl = reflect(-o.worldViewDirection,o.worldNormal);
                TRANSFER_SHADOW(o);
                return o;
            }

            //计算菲涅尔反射，然后怀念和漫反射光照和反射
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDirection);      

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                fixed3 reflection = texCUBE(_Cubemap,i.worldRefl).rgb;

                fixed3 fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir,worldNormal),5);

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));

                fixed shadow = SHADOW_ATTENUATION(i);

                fixed3 color = ambient + lerp(diffuse , reflection , saturate(fresnel)) * atten;
                return fixed4 ( color , 1.0 );
            }
            ENDCG
        } 

    }
    
    FallBack "Refrective/VertexLit"
}
