using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 屏幕后处理，调整亮度，饱和度
/// </summary>
public class BrightnessSaturationAndContrast : PostEffectBase
{
    private void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (material == null)
            return;

        material.SetFloat( "_Brightness", brightness );
        material.SetFloat( "_Saturation", saturation );
        material.SetFloat( "_Contrast", contrast );

        Graphics.Blit( source, destination, material );
    }

    /// <summary>
    /// 获取该材质
    /// </summary>
    public Material material
    {
        get
        {
            if (_mat == null)
                _mat = CheckShaderAndCreateMaterial( _briSatConShader, _mat );

            return _mat;
        }
    }

    /// <summary>
    /// 对比度
    /// </summary>
    [Range( 0f, 3f )] public float contrast = 1.0f;

    /// <summary>
    /// 饱和度
    /// </summary>
    [Range( 0f, 3f )] public float saturation = 1.0f;

    /// <summary>
    /// 亮度
    /// </summary>
    [Range( 0f, 3f )] public float brightness = 1.0f;

    private Material _mat;

    /// <summary>
    /// 该效果需要的shader
    /// </summary>
    [SerializeField] Shader _briSatConShader;
}
