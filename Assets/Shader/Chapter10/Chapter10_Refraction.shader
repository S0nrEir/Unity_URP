// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderBook/Chapter10_Refraction"
{
    Properties
    {
        _Color("Color Tint",Color) = (1,1,1,1)
        _RefractColor("Refract Color",Color) = (1,1,1,1)
        _RefractAmount("Retract Amount",Range(0,1)) = 1
        //透射比
        _RefractRatio("Refract Ratio",Range(0.1,1)) = 0.5
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
            fixed4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;
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
                fixed3 worldRefr          : TEXCOORD3;//反射方向
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldViewDirection = UnityWorldSpaceViewDir(o.worldPos);
                // o.worldRefl = reflect(-o.worldViewDirection,o.worldNormal);//计算反射方向
                //折射方向
                o.worldRefr = refract(-normalize(o.worldViewDirection) , normalize(o.worldNormal) , _RefractRatio);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDirection);      

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));

                fixed shadow = SHADOW_ATTENUATION(i);

                //立方体纹理采样
                fixed3 refraction = texCUBE(_Cubemap,i.worldRefr).rgb * _RefractColor.rgb;

                fixed3 color = ambient + lerp(diffuse , refraction , _RefractAmount);
                return fixed4 ( color * shadow , 1 );
            }
            ENDCG
        } 

    }
    
    FallBack "Refrective/VertexLit"
}
