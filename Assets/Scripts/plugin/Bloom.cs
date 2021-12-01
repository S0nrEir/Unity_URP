using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
{

    //bloom的基本思路是，设定一个阈值，然后根据该阈值提取出图像中亮度较高的区域，与原图进行混合
    //另外bloom的效果建立在高斯模糊上，所以需要一个高斯模糊的shader后处理
    private void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (Mat is null)
        {
            Graphics.Blit( source, destination );
            return;
        }

        int rtW = source.width / _downSample;
        int rtH = source.height / _downSample;

        RenderTexture buffer_0 = RenderTexture.GetTemporary( rtW, rtH, 0 );
        buffer_0.filterMode = FilterMode.Bilinear;
        //提取高亮区域
        Graphics.Blit( source, buffer_0, Mat, 0 );
        for (int i = 0; i < _iteration; i++)
        {
            //第一次模糊
            Mat.SetFloat( "_BlurSize", 1F + i * _blurSpread );
            RenderTexture buffer_1 = RenderTexture.GetTemporary( rtW, rtH, 0 );
            Graphics.Blit( buffer_0, buffer_1 ,Mat,1);

            RenderTexture.ReleaseTemporary( buffer_0 );
            buffer_0 = buffer_1;
            buffer_1 = RenderTexture.GetTemporary( rtW, rtH, 0 );

            //第二次模糊
            Graphics.Blit( buffer_0, buffer_1, Mat, 2 );
            RenderTexture.ReleaseTemporary( buffer_0 );
            buffer_0 = buffer_1;

        }

        //混合
        Mat.SetTexture( "_BloomTex", buffer_0 );
        Graphics.Blit( source, destination, Mat, 3 );

        RenderTexture.ReleaseTemporary( buffer_0 );
    }



    /// <summary>
    /// 亮度阈值
    /// </summary>
    [Range( 0f, 4f )] [SerializeField] private float _luminanceThreshold = .6f;

    [Range( 1, 8 )] [SerializeField] private int _downSample= 1;

    [Range( .2f,3f )] [SerializeField] private float _blurSpread = 3;

    /// <summary>
    /// 高斯模糊轮询次数
    /// </summary>
    [Range( 0, 4 )] [SerializeField] private int _iteration = 3;


    public Material Mat
    {
        get
        {
            if (_matToRender is null)
                _matToRender = CheckShaderAndCreateMaterial(_bloomShader,_matToRender);

            return _matToRender;
        }
    }
    private Material _matToRender;
    [SerializeField] private Shader _bloomShader;
}
