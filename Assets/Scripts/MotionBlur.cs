using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase
{

    private void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (mat == null)
        {
            Graphics.Blit( source, destination );
            return;
        }

        if (_acculationTex == null || _acculationTex.width != source.width || _acculationTex.height != source.height)
        {
            DestroyImmediate( _acculationTex );
            _acculationTex = new RenderTexture( source.width, source.height ,0);
            _acculationTex.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit( source, _acculationTex );
        }

        _acculationTex.MarkRestoreExpected();
        mat.SetFloat( "_BlurAmount", 1f - _blurAmount );
        Graphics.Blit( source, _acculationTex, mat );
        Graphics.Blit( _acculationTex, destination );

    }

    private void OnDisable ()
    {
        //这样做是为了在下次加载时重新叠加图像
        DestroyImmediate( _acculationTex );
    }

    private RenderTexture _acculationTex = null;

    /// <summary>
    /// 模糊程度
    /// </summary>
    [Range( 0f, 0.9f )] [SerializeField] private float _blurAmount = 0.5f;


    public Material mat
    {
        get
        {
            _motionBlurMat = CheckShaderAndCreateMaterial( _motionBlurShader, _motionBlurMat );
            return _motionBlurMat;
        }

    }
    [SerializeField] private Shader _motionBlurShader;
    private Material _motionBlurMat = null;
}
