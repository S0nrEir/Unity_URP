using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BumpSpecualrController : MonoBehaviour
{

    private void OnEnable ()
    {
        var meshRender = GetComponent<MeshRenderer>();
        if (meshRender == null)
            return;

        meshRender.material.SetColor( "_Color", _color );
    }

    [SerializeField] private Color _color = Color.white;
}
