using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectBase
{
    private void DoGaussianBlur (RenderTexture source, RenderTexture destination)
    {
        var rtW = source.width;
        var rtH = source.height;
        RenderTexture buffer = RenderTexture.GetTemporary( rtW, rtH, 0 );

        //垂直滤波
        Graphics.Blit( source, buffer, mat, 0 );
        //横向滤波
        //将前一次滤波的图像保存到buffe里再进行第二次滤波
        Graphics.Blit( buffer, destination, mat, 1 );

        RenderTexture.ReleaseTemporary( buffer );
    }

    private void DoGaussianBlurOpt_1 (RenderTexture source, RenderTexture destination)
    {
        var rtW = source.width / _downSample;
        var rtH = source.height / _downSample;
        RenderTexture buffer = RenderTexture.GetTemporary( rtW, rtH, 0 );
        //滤波模式改成双线性
        buffer.filterMode = FilterMode.Bilinear;

        //垂直滤波
        Graphics.Blit( source, buffer, mat, 0 );
        //横向滤波
        //将前一次滤波的图像保存到buffe里再进行第二次滤波
        Graphics.Blit( buffer, destination, mat, 1 );

        RenderTexture.ReleaseTemporary( buffer );
    }

    /// <summary>
    /// 这个版本的模糊使用了两个buffer在迭代间，进行交替
    /// </summary>
    private void DoGaussianBlurOpt_2 (RenderTexture source, RenderTexture destination)
    {
        var rtW = source.width / _downSample;
        var rtH = source.height / _downSample;
        
        RenderTexture buffer_0 = RenderTexture.GetTemporary( rtW, rtH, 0 );
        //滤波模式改成双线性
        buffer_0.filterMode = FilterMode.Bilinear;

        //source中的图像缩放后存到buffer0当中
        Graphics.Blit( source, buffer_0 );
        
        for (int i = 0; i < _iterations; i++)
        {
            mat.SetFloat( "_BlurSize", 1.0f + i * _blurSpread );
            //do pass 0
            RenderTexture buffer_1 = RenderTexture.GetTemporary( rtW, rtH, 0 );

            Graphics.Blit( buffer_0, buffer_1, mat, 0 );
            RenderTexture.ReleaseTemporary( buffer_0 );
            //执行完第一个pass后将结果图像返回给buffer0
            buffer_0 = buffer_1;
            buffer_1 = RenderTexture.GetTemporary( rtW, rtH, 0 );

            //do pass 1
            Graphics.Blit( buffer_0, buffer_1, mat, 1 );

            RenderTexture.ReleaseTemporary( buffer_0 );
            //跑完第二个pass再次将结果保存到buffer0里
            buffer_0 = buffer_1;
        }

        Graphics.Blit( buffer_0, destination );
        RenderTexture.ReleaseTemporary( buffer_0 );
    }

    private void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (mat is null)
        {
            Graphics.Blit( source, destination);
            return;
        }

        DoGaussianBlurOpt_2( source, destination );
    }


    /// <summary>
    /// downSample越大，处理像素越少
    /// </summary>
    [Range( 1, 8 )] public int _downSample = 2;
    [Range( 0.2f, 3.0f )] public float _blurSpread = .6f;

    [Range( 0, 4 )] public int _iterations = 3;

    public Material mat
    {
        get
        {
            if (_gaussianBlurMat == null)
                _gaussianBlurMat = CheckShaderAndCreateMaterial( _gaussianBlurShader, _gaussianBlurMat );

            return _gaussianBlurMat;
        }
    }

    /// <summary>
    /// 模糊材质
    /// </summary>
    private Material _gaussianBlurMat;

    /// <summary>
    /// 高斯模糊shader
    /// </summary>
    [SerializeField] private Shader _gaussianBlurShader;
}
