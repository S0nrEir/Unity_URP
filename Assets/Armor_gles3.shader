//////////////////////////////////////////
//
// NOTE: This is *not* a valid shader file
//
///////////////////////////////////////////
Shader "#Armor/gles3" {
Properties {
_Tex1 ("Texture (UV1)", 2D) = "white" { }
_Color1 ("Color", Color) = (1,1,1,1)
_Intensity1 ("Intensity", Range(0, 3)) = 1
[Space(30)] _Tex2 ("Texture [Add] (UV1)", 2D) = "black" { }
_Color2 ("Color", Color) = (1,1,1,1)
_Intensity2 ("Intensity", Range(0, 3)) = 1
[Space(30)] _Tex3 ("Texture [Add] (UV2)", 2D) = "black" { }
_Color3 ("Color", Color) = (1,1,1,1)
_Intensity3 ("Intensity", Range(0, 3)) = 1
_HoleAlpha ("Hole Alpha", Range(0, 1)) = 0
[Space(30)] _Tex4 ("Sprite Sheet [Add] (UV2)", 2D) = "black" { }
_Intensity4 ("Intensity", Range(0, 3)) = 1
_SSRow ("Sprite Sheet Rows", Float) = 1
_SSColumn ("Sprite Sheet Columns", Float) = 1
_SSTime ("Sprite Sheet Time", Range(0, 0.9999)) = 0
[Space(30)] _Tex5 ("Texture [Mult] (UV1)", 2D) = "white" { }
_MasterOpacity ("Master Opacity", Range(0, 1)) = 1
}
SubShader {
 Tags { "QUEUE" = "Transparent" }
 Pass {
  Tags { "QUEUE" = "Transparent" }
  ZWrite Off
  Cull Off
  GpuProgramID 19313
Program "vp" {
SubProgram "gles3 hw_tier00 " {"
#ifdef VERTEX
#version 300 es

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 _Tex1_ST;
uniform 	vec4 _Tex2_ST;
uniform 	vec4 _Tex3_ST;
uniform 	mediump float _SSRow;
uniform 	mediump float _SSColumn;
uniform 	mediump float _SSTime;
uniform 	vec4 _Tex5_ST;
in highp vec4 in_POSITION0;
in mediump vec4 in_COLOR0;
in highp vec2 in_TEXCOORD0;
in highp vec2 in_TEXCOORD1;
out mediump vec4 vs_COLOR0;
out highp vec2 vs_TEXCOORD0;
out highp vec2 vs_TEXCOORD1;
out highp vec2 vs_TEXCOORD2;
out highp vec2 vs_TEXCOORD3;
out highp vec2 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
mediump vec2 u_xlat16_2;
float u_xlat3;
float u_xlat6;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat1;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
    vs_COLOR0 = in_COLOR0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy * _Tex1_ST.xy + _Tex1_ST.zw;
    vs_TEXCOORD1.xy = in_TEXCOORD0.xy * _Tex2_ST.xy + _Tex2_ST.zw;
    u_xlat0.x = in_TEXCOORD1.y / _SSRow;
    u_xlat16_2.xy = vec2(vec2(_SSRow, _SSRow)) * vec2(_SSColumn, _SSTime);
    u_xlat16_2.x = u_xlat16_2.x * _SSTime;
    u_xlat16_2.xy = floor(u_xlat16_2.xy);
    u_xlat3 = u_xlat16_2.x / _SSColumn;
    u_xlat6 = u_xlat16_2.y / _SSRow;
    u_xlat0.x = (-u_xlat6) + u_xlat0.x;
    u_xlat16_2.x = float(1.0) / _SSRow;
    vs_TEXCOORD3.y = u_xlat0.x + (-u_xlat16_2.x);
    u_xlat0.x = in_TEXCOORD1.x / _SSColumn;
    vs_TEXCOORD3.x = u_xlat3 + u_xlat0.x;
    vs_TEXCOORD2.xy = in_TEXCOORD1.xy * _Tex3_ST.xy + _Tex3_ST.zw;
    vs_TEXCOORD4.xy = in_TEXCOORD0.xy * _Tex5_ST.xy + _Tex5_ST.zw;
    return; 
}

#endif
#ifdef FRAGMENT
#version 300 es

precision highp float;
precision highp int;
uniform 	mediump vec4 _Color1;
uniform 	mediump float _Intensity1;
uniform 	mediump vec4 _Color2;
uniform 	mediump float _Intensity2;
uniform 	mediump vec4 _Color3;
uniform 	mediump float _Intensity3;
uniform 	mediump float _HoleAlpha;
uniform 	mediump float _Intensity4;
uniform 	mediump float _MasterOpacity;
uniform mediump sampler2D _Tex1;
uniform mediump sampler2D _Tex2;
uniform mediump sampler2D _Tex3;
uniform mediump sampler2D _Tex4;
uniform mediump sampler2D _Tex5;
in mediump vec4 vs_COLOR0;
in highp vec2 vs_TEXCOORD0;
in highp vec2 vs_TEXCOORD1;
in highp vec2 vs_TEXCOORD2;
in highp vec2 vs_TEXCOORD3;
in highp vec2 vs_TEXCOORD4;
layout(location = 0) out mediump vec4 SV_Target0;
mediump vec4 u_xlat16_0;
mediump vec4 u_xlat16_1;
mediump vec3 u_xlat16_2;
mediump vec3 u_xlat16_3;
void main()
{
    u_xlat16_0.xyz = texture(_Tex2, vs_TEXCOORD1.xy).xyz;
    u_xlat16_1.xyz = u_xlat16_0.xyz * _Color2.xyz;
    u_xlat16_1.xyz = u_xlat16_1.xyz * vec3(_Intensity2);
    u_xlat16_0.xyz = texture(_Tex1, vs_TEXCOORD0.xy).xyz;
    u_xlat16_2.xyz = u_xlat16_0.xyz * _Color1.xyz;
    u_xlat16_0.xyz = u_xlat16_2.xyz * vec3(_Intensity1) + u_xlat16_1.xyz;
    u_xlat16_1 = texture(_Tex3, vs_TEXCOORD2.xy);
    u_xlat16_2.xyz = u_xlat16_1.xyz * _Color3.xyz;
    u_xlat16_1.w = u_xlat16_1.w + _HoleAlpha;
#ifdef UNITY_ADRENO_ES3
    u_xlat16_1.w = min(max(u_xlat16_1.w, 0.0), 1.0);
#else
    u_xlat16_1.w = clamp(u_xlat16_1.w, 0.0, 1.0);
#endif
    u_xlat16_1.xyz = u_xlat16_2.xyz * vec3(_Intensity3);
    u_xlat16_0.w = 0.0;
    u_xlat16_0 = u_xlat16_0 + u_xlat16_1;
    u_xlat16_3.xyz = texture(_Tex4, vs_TEXCOORD3.xy).xyz;
    u_xlat16_1.xyz = u_xlat16_3.xyz * vec3(vec3(_Intensity4, _Intensity4, _Intensity4));
    u_xlat16_1.w = 0.0;
    u_xlat16_0 = u_xlat16_0 + u_xlat16_1;
    u_xlat16_1 = texture(_Tex5, vs_TEXCOORD4.xy);
    u_xlat16_0 = u_xlat16_0 * u_xlat16_1;
    u_xlat16_0 = u_xlat16_0 * vs_COLOR0;
    SV_Target0 = u_xlat16_0 * vec4(_MasterOpacity);
    return;
}

#endif
"
}
SubProgram "gles3 hw_tier01 " {"
#ifdef VERTEX
#version 300 es

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 _Tex1_ST;
uniform 	vec4 _Tex2_ST;
uniform 	vec4 _Tex3_ST;
uniform 	mediump float _SSRow;
uniform 	mediump float _SSColumn;
uniform 	mediump float _SSTime;
uniform 	vec4 _Tex5_ST;
in highp vec4 in_POSITION0;
in mediump vec4 in_COLOR0;
in highp vec2 in_TEXCOORD0;
in highp vec2 in_TEXCOORD1;
out mediump vec4 vs_COLOR0;
out highp vec2 vs_TEXCOORD0;
out highp vec2 vs_TEXCOORD1;
out highp vec2 vs_TEXCOORD2;
out highp vec2 vs_TEXCOORD3;
out highp vec2 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
mediump vec2 u_xlat16_2;
float u_xlat3;
float u_xlat6;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat1;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
    vs_COLOR0 = in_COLOR0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy * _Tex1_ST.xy + _Tex1_ST.zw;
    vs_TEXCOORD1.xy = in_TEXCOORD0.xy * _Tex2_ST.xy + _Tex2_ST.zw;
    u_xlat0.x = in_TEXCOORD1.y / _SSRow;
    u_xlat16_2.xy = vec2(vec2(_SSRow, _SSRow)) * vec2(_SSColumn, _SSTime);
    u_xlat16_2.x = u_xlat16_2.x * _SSTime;
    u_xlat16_2.xy = floor(u_xlat16_2.xy);
    u_xlat3 = u_xlat16_2.x / _SSColumn;
    u_xlat6 = u_xlat16_2.y / _SSRow;
    u_xlat0.x = (-u_xlat6) + u_xlat0.x;
    u_xlat16_2.x = float(1.0) / _SSRow;
    vs_TEXCOORD3.y = u_xlat0.x + (-u_xlat16_2.x);
    u_xlat0.x = in_TEXCOORD1.x / _SSColumn;
    vs_TEXCOORD3.x = u_xlat3 + u_xlat0.x;
    vs_TEXCOORD2.xy = in_TEXCOORD1.xy * _Tex3_ST.xy + _Tex3_ST.zw;
    vs_TEXCOORD4.xy = in_TEXCOORD0.xy * _Tex5_ST.xy + _Tex5_ST.zw;
    return;
}

#endif
#ifdef FRAGMENT
#version 300 es

precision highp float;
precision highp int;
uniform 	mediump vec4 _Color1;
uniform 	mediump float _Intensity1;
uniform 	mediump vec4 _Color2;
uniform 	mediump float _Intensity2;
uniform 	mediump vec4 _Color3;
uniform 	mediump float _Intensity3;
uniform 	mediump float _HoleAlpha;
uniform 	mediump float _Intensity4;
uniform 	mediump float _MasterOpacity;
uniform mediump sampler2D _Tex1;
uniform mediump sampler2D _Tex2;
uniform mediump sampler2D _Tex3;
uniform mediump sampler2D _Tex4;
uniform mediump sampler2D _Tex5;
in mediump vec4 vs_COLOR0;
in highp vec2 vs_TEXCOORD0;
in highp vec2 vs_TEXCOORD1;
in highp vec2 vs_TEXCOORD2;
in highp vec2 vs_TEXCOORD3;
in highp vec2 vs_TEXCOORD4;
layout(location = 0) out mediump vec4 SV_Target0;
mediump vec4 u_xlat16_0;
mediump vec4 u_xlat16_1;
mediump vec3 u_xlat16_2;
mediump vec3 u_xlat16_3;
void main()
{
    u_xlat16_0.xyz = texture(_Tex2, vs_TEXCOORD1.xy).xyz;
    u_xlat16_1.xyz = u_xlat16_0.xyz * _Color2.xyz;
    u_xlat16_1.xyz = u_xlat16_1.xyz * vec3(_Intensity2);
    u_xlat16_0.xyz = texture(_Tex1, vs_TEXCOORD0.xy).xyz;
    u_xlat16_2.xyz = u_xlat16_0.xyz * _Color1.xyz;
    u_xlat16_0.xyz = u_xlat16_2.xyz * vec3(_Intensity1) + u_xlat16_1.xyz;
    u_xlat16_1 = texture(_Tex3, vs_TEXCOORD2.xy);
    u_xlat16_2.xyz = u_xlat16_1.xyz * _Color3.xyz;
    u_xlat16_1.w = u_xlat16_1.w + _HoleAlpha;
#ifdef UNITY_ADRENO_ES3
    u_xlat16_1.w = min(max(u_xlat16_1.w, 0.0), 1.0);
#else
    u_xlat16_1.w = clamp(u_xlat16_1.w, 0.0, 1.0);
#endif
    u_xlat16_1.xyz = u_xlat16_2.xyz * vec3(_Intensity3);
    u_xlat16_0.w = 0.0;
    u_xlat16_0 = u_xlat16_0 + u_xlat16_1;
    u_xlat16_3.xyz = texture(_Tex4, vs_TEXCOORD3.xy).xyz;
    u_xlat16_1.xyz = u_xlat16_3.xyz * vec3(vec3(_Intensity4, _Intensity4, _Intensity4));
    u_xlat16_1.w = 0.0;
    u_xlat16_0 = u_xlat16_0 + u_xlat16_1;
    u_xlat16_1 = texture(_Tex5, vs_TEXCOORD4.xy);
    u_xlat16_0 = u_xlat16_0 * u_xlat16_1;
    u_xlat16_0 = u_xlat16_0 * vs_COLOR0;
    SV_Target0 = u_xlat16_0 * vec4(_MasterOpacity);
    return;
}

#endif
"
}
SubProgram "gles3 hw_tier02 " {
"#ifdef VERTEX
#version 300 es

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 _Tex1_ST;
uniform 	vec4 _Tex2_ST;
uniform 	vec4 _Tex3_ST;
uniform 	mediump float _SSRow;
uniform 	mediump float _SSColumn;
uniform 	mediump float _SSTime;
uniform 	vec4 _Tex5_ST;
in highp vec4 in_POSITION0;
in mediump vec4 in_COLOR0;
in highp vec2 in_TEXCOORD0;
in highp vec2 in_TEXCOORD1;
out mediump vec4 vs_COLOR0;
out highp vec2 vs_TEXCOORD0;
out highp vec2 vs_TEXCOORD1;
out highp vec2 vs_TEXCOORD2;
out highp vec2 vs_TEXCOORD3;
out highp vec2 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
mediump vec2 u_xlat16_2;
float u_xlat3;
float u_xlat6;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat0 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz + u_xlat1;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww + u_xlat1;
    vs_COLOR0 = in_COLOR0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy * _Tex1_ST.xy + _Tex1_ST.zw;
    vs_TEXCOORD1.xy = in_TEXCOORD0.xy * _Tex2_ST.xy + _Tex2_ST.zw;
    u_xlat0.x = in_TEXCOORD1.y / _SSRow;
    u_xlat16_2.xy = vec2(vec2(_SSRow, _SSRow)) * vec2(_SSColumn, _SSTime);
    u_xlat16_2.x = u_xlat16_2.x * _SSTime;
    u_xlat16_2.xy = floor(u_xlat16_2.xy);
    u_xlat3 = u_xlat16_2.x / _SSColumn;
    u_xlat6 = u_xlat16_2.y / _SSRow;
    u_xlat0.x = (-u_xlat6) + u_xlat0.x;
    u_xlat16_2.x = float(1.0) / _SSRow;
    vs_TEXCOORD3.y = u_xlat0.x + (-u_xlat16_2.x);
    u_xlat0.x = in_TEXCOORD1.x / _SSColumn;
    vs_TEXCOORD3.x = u_xlat3 + u_xlat0.x;
    vs_TEXCOORD2.xy = in_TEXCOORD1.xy * _Tex3_ST.xy + _Tex3_ST.zw;
    vs_TEXCOORD4.xy = in_TEXCOORD0.xy * _Tex5_ST.xy + _Tex5_ST.zw;
    return;
}

#endif
#ifdef FRAGMENT
#version 300 es

precision highp float;
precision highp int;
uniform 	mediump vec4 _Color1;
uniform 	mediump float _Intensity1;
uniform 	mediump vec4 _Color2;
uniform 	mediump float _Intensity2;
uniform 	mediump vec4 _Color3;
uniform 	mediump float _Intensity3;
uniform 	mediump float _HoleAlpha;
uniform 	mediump float _Intensity4;
uniform 	mediump float _MasterOpacity;
uniform mediump sampler2D _Tex1;
uniform mediump sampler2D _Tex2;
uniform mediump sampler2D _Tex3;
uniform mediump sampler2D _Tex4;
uniform mediump sampler2D _Tex5;
in mediump vec4 vs_COLOR0;
in highp vec2 vs_TEXCOORD0;
in highp vec2 vs_TEXCOORD1;
in highp vec2 vs_TEXCOORD2;
in highp vec2 vs_TEXCOORD3;
in highp vec2 vs_TEXCOORD4;
layout(location = 0) out mediump vec4 SV_Target0;
mediump vec4 u_xlat16_0;
mediump vec4 u_xlat16_1;
mediump vec3 u_xlat16_2;
mediump vec3 u_xlat16_3;
void main()
{
    u_xlat16_0.xyz = texture(_Tex2, vs_TEXCOORD1.xy).xyz;
    u_xlat16_1.xyz = u_xlat16_0.xyz * _Color2.xyz;
    u_xlat16_1.xyz = u_xlat16_1.xyz * vec3(_Intensity2);
    u_xlat16_0.xyz = texture(_Tex1, vs_TEXCOORD0.xy).xyz;
    u_xlat16_2.xyz = u_xlat16_0.xyz * _Color1.xyz;
    u_xlat16_0.xyz = u_xlat16_2.xyz * vec3(_Intensity1) + u_xlat16_1.xyz;
    u_xlat16_1 = texture(_Tex3, vs_TEXCOORD2.xy);
    u_xlat16_2.xyz = u_xlat16_1.xyz * _Color3.xyz;
    u_xlat16_1.w = u_xlat16_1.w + _HoleAlpha;
#ifdef UNITY_ADRENO_ES3
    u_xlat16_1.w = min(max(u_xlat16_1.w, 0.0), 1.0);
#else
    u_xlat16_1.w = clamp(u_xlat16_1.w, 0.0, 1.0);
#endif
    u_xlat16_1.xyz = u_xlat16_2.xyz * vec3(_Intensity3);
    u_xlat16_0.w = 0.0;
    u_xlat16_0 = u_xlat16_0 + u_xlat16_1;
    u_xlat16_3.xyz = texture(_Tex4, vs_TEXCOORD3.xy).xyz;
    u_xlat16_1.xyz = u_xlat16_3.xyz * vec3(vec3(_Intensity4, _Intensity4, _Intensity4));
    u_xlat16_1.w = 0.0;
    u_xlat16_0 = u_xlat16_0 + u_xlat16_1;
    u_xlat16_1 = texture(_Tex5, vs_TEXCOORD4.xy);
    u_xlat16_0 = u_xlat16_0 * u_xlat16_1;
    u_xlat16_0 = u_xlat16_0 * vs_COLOR0;
    SV_Target0 = u_xlat16_0 * vec4(_MasterOpacity);
    return;
}

#endif
"
}
}
Program "fp" {
SubProgram "gles3 hw_tier00 " {
""
}
SubProgram "gles3 hw_tier01 " {
""
}
SubProgram "gles3 hw_tier02 " {
""
}
}
}
}
}