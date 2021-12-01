using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 基于噪点图的全局雾效
/// </summary>
public class FogWithNoise : PostEffectBase
{
    private void OnEnable ()
    {
        _camera = GetComponent<Camera>();
        if (_camera == null)
            return;

        //获取相机深度纹理
        _camera.depthTextureMode |= DepthTextureMode.Depth;

        //设置相机参数
        _fov = _camera.fieldOfView;
        _near = _camera.nearClipPlane;
        _aspect = _camera.aspect;

        //缓存transform
        cached_camera_tran = _camera.transform;
    }

    private void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (material is null)
        {
            Graphics.Blit( source, destination );
            return;
        }
        //单位矩阵
        Matrix4x4 frustum_corners = Matrix4x4.identity;
        var halfHeight = _near * Mathf.Tan( _fov * .5f * Mathf.Deg2Rad );
        Vector3 toRight = cached_camera_tran.right * halfHeight * _aspect;
        Vector3 toTop   = cached_camera_tran.up * halfHeight;

        //计算近裁面的四个角
        var topLeft = cached_camera_tran.forward * _near + toTop - toRight;
        var scale = topLeft.magnitude / _near;

        topLeft.Normalize();
        topLeft *= scale;

        var topRight = cached_camera_tran.forward * _near + toTop + toRight;
        topRight.Normalize();
        topRight *= scale;

        var bottomLeft = cached_camera_tran.forward * _near - toTop - toRight;
        bottomLeft.Normalize();
        bottomLeft *= scale;

        var bottomRight = cached_camera_tran.forward * _near - toTop + toRight;
        bottomRight.Normalize();
        bottomRight *= scale;

        frustum_corners.SetRow( 0, bottomLeft );
        frustum_corners.SetRow( 1, bottomRight );
        frustum_corners.SetRow( 2, topRight );
        frustum_corners.SetRow( 3, topLeft );

        material.SetMatrix( "_FrustumCornersRay", frustum_corners );
        material.SetFloat( "_FogDensity", fog_density );
        material.SetColor( "_FogColor", _fogColor );
        material.SetFloat( "_FogStart", fog_start );
        material.SetFloat( "_FogEnd", fog_end );

        material.SetTexture( "_NoiseTex", noise_tex );
        material.SetFloat( "_FogXSpeed", fog_x_speed );
        material.SetFloat( "_FogYSpeed", fog_y_speed );
        material.SetFloat( "_NoiseAmount", noise_amount );

        Graphics.Blit( source, destination, material );

    }

    private float _fov = 0;
    private float _near = 0;
    private float _aspect = 0;

    /// <summary>
    /// 噪点系数
    /// </summary>
    [Range( 0, 3f )] [SerializeField] private float noise_amount = 1f;

    /// <summary>
    /// 雾效Y速度
    /// </summary>
    [Range( -.5f, .5f )] [SerializeField] float fog_y_speed = .1f;

    /// <summary>
    /// 雾效X速度
    /// </summary>
    [Range( -.5f, .5f )] [SerializeField] float fog_x_speed = .1f;

    /// <summary>
    /// 噪点图
    /// </summary>
    [SerializeField] private Texture noise_tex;

    /// <summary>
    /// 雾效结束位置
    /// </summary>
    [SerializeField] private float fog_end = 0f;

    /// <summary>
    /// 雾效起始位置
    /// </summary>
    [SerializeField] private float fog_start = 0f;

    /// <summary>
    /// 雾效浓度
    /// </summary>
    [Range( .1f, 3f )] [SerializeField] private float fog_density = 1f;

    /// <summary>
    /// 雾效颜色
    /// </summary>
    [SerializeField] private Color _fogColor = Color.white;


    private Transform cached_camera_tran;
    private Camera _camera;

    public Material material
    {
        get
        {
            if (_mat is null)
                _mat = CheckShaderAndCreateMaterial( fog_shader, _mat );

            return _mat;
        }
    }

    private Material _mat = null;

    /// <summary>
    /// 雾效shader
    /// </summary>
    [SerializeField] private Shader fog_shader;
}
