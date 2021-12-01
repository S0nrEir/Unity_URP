using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveController : MonoBehaviour
{
    private void OnEnable ()
    {
        var meshRender = GetComponent<MeshRenderer>();
        if (meshRender is null)
            return;

        _cachedMat = meshRender.material;
    }

    private void Update ()
    {
        factor = Mathf.Sin( Time.time);
        _burnAmount = factor;
        _cachedMat.SetFloat( "_BurnAmount", _burnAmount);
    }

    private float factor = 0f;
    private Material _cachedMat;

    [SerializeField] [Range( 0f, 1f )] private float _burnAmount = 0f;
}
