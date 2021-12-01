using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectBase
{


    private void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat( "_EdgeOnly", edgeOnly );
            material.SetColor( "_EdgeColor", edgeColor );
            material.SetColor( "_BackGroundColor", backGroundColor );

            Graphics.Blit( source, destination, material );
        }
        else
        {
            Debug.Log("<color=white>rendering as normal mode...</color>");
            Graphics.Blit( source, destination );
        }
    }

    /// <summary>
    /// 背景色
    /// </summary>
    public Color backGroundColor = Color.black;

    /// <summary>
    /// 边缘色
    /// </summary>
    public Color edgeColor = Color.black;

    /// <summary>
    /// 该值为0时，边缘将会叠加在原渲染图像上，为1则只显示边缘
    /// </summary>
    [Range( 0.0f, 1.0f )] public float edgeOnly = 0.0f;

    public Material material
    {
        get
        {
            if (mat == null)
                mat = CheckShaderAndCreateMaterial( _edgeDetectionShader, mat );

            return mat;
        }
    }

    /// <summary>
    /// 临时材质
    /// </summary>
    private Material mat = null;

    /// <summary>
    /// 边缘检测实现的shader
    /// </summary>
    [SerializeField] private Shader _edgeDetectionShader;
}
