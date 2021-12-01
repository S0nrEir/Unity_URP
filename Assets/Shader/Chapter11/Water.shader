// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderBook/Chapter11/Water"
{
    Properties
    {
        //2D水面波动纹理
        _MainTex("Main Tex",2D) = "white"{}
        _Color("Color Tint",Color) = (1,1,1,1)
        //水流波动幅度
        _Magnitude("Distortion Magnitude",Float) = 1
        //波动频率
        _Frequency("Distortion Frequency",Float) = 1
        //波长的倒数，即该值越大波长越小
        _InvWaveLength("Wave Len",Float) = 10
        //纹理移动速度
        _Speed("Speed",Float) = 0.5
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

            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM

            //#pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag 
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _MainTex_ST;

            fixed4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0; 
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            //获取水面波动x轴偏移
            float get_offset_x(float4 vertex)
            {
                //Frequency控制函数波动频率
                //Magnitude平滑程度
                //加上不同的顶点位置，是因为每个顶点分量不一样，偏移后的位置也各不相同，比如坐下坐标顶点为（0,0,0），则其最大偏移范围为-1~1（不考虑波长）
                //而对于另外一个顶点，它本来的顶点位置可能是（0,1,0），那么在同一时刻他们偏移的顶点位置各个轴向就是不相同的，以此造成偏移的效果
                return sin(_Frequency * _Time.y + vertex.x * _InvWaveLength + vertex.y * _InvWaveLength + vertex.z * _InvWaveLength) * _Magnitude;
                //return sin(_Frequency * _Time.y + vertex.x * _InvWaveLength + vertex.z * _InvWaveLength) * _Magnitude;
                //return sin(_Frequency * _Time.y + (vertex.x + _InvWaveLength) + (vertex.y + _InvWaveLength) + (vertex.z + _InvWaveLength)) * _Magnitude;
            }

            v2f vert(a2v v)
            {
                v2f o;

                float4 offset;
                offset.yzw = float3(0,0,0);
                //计算顶点位移量，因为只希望对x进行位移，所以其他三个分量不用管
                offset.x = get_offset_x(v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv += float2(0,_Time.y * _Speed);

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
