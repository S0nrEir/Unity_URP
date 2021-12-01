// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderBook/Chapter11/BillBoard"
{
    Properties
    {
    	//透明纹理
        _MainTex("Main Tex",2D) = "white"{}
        //整体颜色
        _Color("Color Tint",Color) = (1,1,1,1)
        //法线指向，固定法线还是指向上的方向，为1表示固定为视角方向
        _VerticalBillboarding("Vertical Retraints",Range(0,1)) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "DisableBatching" = "True"//合批会导致丢失模型空间坐标丢失
        }
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"                
            }           

            //为了让每个面都能显示
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM

            //#pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag 
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _VerticalBillboarding;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0; 
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
            	v2f o;
            	//模型空间原点作为锚点
            	float3 center = (0,0,0);
            	//模型空间下的视角位置
            	float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
            	//获取模型空间下的法线方向
            	float3 normalDir = viewer - center;
            	normalDir.y = normalDir.y * _VerticalBillboarding;
            	normalDir = normalize(normalDir);
            	//根据法线方向确定上方向
            	//这是因为，当视角方向为上时，法线方向和上方向重合
            	float3 upDir = abs(normalDir.y) > 0.999 ? float3(0,0,1) : float3(0,1,0);
            	float3 rightDir = normalize(cross(upDir,normalDir));
            	upDir = normalize(cross(normalDir,rightDir));

            	//算出三个正交基，根据原始的顶点位置相对于锚点的偏移量，以此为依据计算新的顶点的位置
            	//顶点相对于中心锚点的偏移量
            	float3 centerOffset = v.vertex.xyz - center;
            	//#todo存疑
            	float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir * centerOffset.z;
            	o.pos = UnityObjectToClipPos(float4(localPos,1));
            	o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex,i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }

            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
