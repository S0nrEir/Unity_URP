using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent( typeof( Camera ) )]
public class PostEffectBase : MonoBehaviour
{
    /// <summary>
    /// 创建渲染纹理的材质和shader
    /// </summary>
    /// <param name="shader">该特效使用的shader</param>
    /// <param name="mat">后处理用的材质</param>
    protected Material CheckShaderAndCreateMaterial (Shader shader, Material mat)
    {
        if (shader == null)
            return null;

        if (!shader.isSupported)
        {
            Debug.Log("<color=red>shader not supported!</color>");
            return null;
        }
        
        if (/*shader.isSupported &&*/ mat && mat.shader == shader)
            return mat;

        mat = new Material( shader );
        mat.hideFlags = HideFlags.DontSave;
        if (mat)
            return mat;
        else
            return null;
    }    

    protected void CheckResources ()
    {
        var isSupported = CheckSupport();
        if (!isSupported)
            NotSupport();
    }

    protected void NotSupport () => enabled = false;

    /// <summary>
    /// 平台支持
    /// </summary>
    protected bool CheckSupport ()
    {
        if (!SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures)
            return false;

        return true;
    }

    public virtual void Start ()
    {
        CheckResources();
    }

    public virtual void Test ()
    {
        CheckResources();
    }
}
