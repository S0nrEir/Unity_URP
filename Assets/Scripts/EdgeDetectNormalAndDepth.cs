using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 基于深度纹理和法线的边缘检测
/// </summary>
public class EdgeDetectNormalAndDepth : PostEffectBase
{

    private void OnEnable ()
    {
        _camera = GetComponent<Camera>();
        if (_camera != null)
            _camera.depthTextureMode |= DepthTextureMode.DepthNormals;

    }

    [ImageEffectOpaque]
    private void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (Mat is null)
        {
            Graphics.Blit( source, destination );
            return;
        }

        Mat.SetFloat( "_EdgesOnly", _edgesOnly );
        Mat.SetColor( "_EdgeColor", _edgeColor );
        Mat.SetColor( "_BackGroundColor", _backGroundColor );
        Mat.SetFloat( "_SampleDistance", _sampleDistance );
        Mat.SetVector( "_Sensitivity", new Vector4(_sensitivityNormals,_sensitivityDepth,0f,0f) );

        Graphics.Blit( source, destination, Mat );
    }

    private Camera _camera = null;

    /// <summary>
    /// 邻域法线检查差值
    /// </summary>
    [SerializeField] private float _sensitivityNormals = 1f;

    /// <summary>
    /// 邻域深度检查差值
    /// </summary>
    [SerializeField] private float _sensitivityDepth = 1f;

    /// <summary>
    /// 边缘采样距离
    /// </summary>
    [SerializeField] private float _sampleDistance = 1f;

    /// <summary>
    /// 边缘背景色
    /// </summary>
    [SerializeField] private Color _backGroundColor = Color.white;

    /// <summary>
    /// 边缘颜色
    /// </summary>
    [SerializeField] private Color _edgeColor = Color.black;

    /// <summary>
    /// 边缘长度
    /// </summary>
    [SerializeField][Range( 0.0f, 1f )] private float _edgesOnly = 0f; 

    public Material Mat
    {
        get
        {
            if (_edgeDetectMat is null)
                _edgeDetectMat = CheckShaderAndCreateMaterial( _edgeDetectShader, _edgeDetectMat );

            return _edgeDetectMat;
        }
    }

    /// <summary>
    /// 材质
    /// </summary>
    private Material _edgeDetectMat = null;

    /// <summary>
    /// 边缘检测shader
    /// </summary>
    [SerializeField] private Shader _edgeDetectShader;
}
