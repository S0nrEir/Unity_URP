using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NRP_Controller : MonoBehaviour
{

    private void OnEnable ()
    {
        var meshRender = GetComponent<SkinnedMeshRenderer>();
        if (meshRender is null)
        {
            Debug.LogError("meshRender is null!");
            return;
        }

        _mat = meshRender.material;
        if (_mat is null || _mainTex is null)
        {
            Debug.LogError( "_mat or mainTex is null!" );
            return;
        }

        _mat.SetTexture( "_MainTex", _mainTex );
    }

    [SerializeField] private Texture _mainTex;
    private Material _mat;
}
