using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MorionBlurDepthTex : PostEffectBase
{
    private void OnEnable ()
    {
        if (camera == null)
            camera = GetComponent<Camera>();

        //设置相机状态，获取相机深度纹理
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (mat == null)
        {
            Graphics.Blit( source, destination );
            return;
        }

        mat.SetFloat( "_BlurSize", _blurSize );
        mat.SetMatrix( "_PreviousViewProjectionMTX", _previousViewProjectionMTX );

        //得到当前视角的投影矩阵，然后求逆，得到由裁剪空间到世界空间的变换矩阵，将其传递给shader用做模糊处理
        Matrix4x4 currViewProjectionMTX = camera.projectionMatrix * camera.worldToCameraMatrix;//世界空间->裁剪空间的变换矩阵
        Matrix4x4 currViewProjectionInverseMTX = currViewProjectionMTX.inverse;//裁剪空间->世界空间
        mat.SetMatrix( "_CurrViewProjectionInverseMTX", currViewProjectionInverseMTX );

        //保存上一帧的矩阵
        _previousViewProjectionMTX = currViewProjectionMTX;

        Graphics.Blit( source, destination, mat );
    }

    /// <summary>
    /// 上一帧相机的投影矩阵
    /// </summary>
    private Matrix4x4 _previousViewProjectionMTX;

    /// <summary>
    /// 因为要得到相机视角和投影矩阵，所以要拿camera
    /// </summary>
    private Camera camera;

    /// <summary>
    /// 模糊图像使用的大小
    /// </summary>
    [Range( 0.0f, 1.0f )] [SerializeField] private float _blurSize = .5f;

    public Material mat => CheckShaderAndCreateMaterial( _motionBlurShader, _motionBlurMat );
    /// <summary>
    /// 材质
    /// </summary>
    private Material _motionBlurMat = null;

    /// <summary>
    /// 动态模糊的shader
    /// </summary>
    [SerializeField] private Shader _motionBlurShader;
}
