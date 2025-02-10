using System.Collections.Generic;
using UnityEngine;

/*
This script is responsible for controlling colliders of ColliderCopy objects.
It also detectes and saves colliders of ColliderCopy objects that will be culled
based on gameplay direction.
Collider sizes and activation are controlled by ColliderManager script.
*/

public class ColliderTransformer : MonoBehaviour
{
    private bool m_Started;
    private Collider[] _hitColliders;

    // save colliders in a bounding box
    public void GetColliders()
    {
        int colliderCopyLayer = LayerMask.NameToLayer("ColliderCopy");
        int layerMask = 1 << colliderCopyLayer;
        _hitColliders = Physics.OverlapBox(gameObject.transform.position, transform.localScale / 2, Quaternion.identity, layerMask);
    }

    public void DeactiveColliders()
    {
        foreach (Collider collider in _hitColliders)
        {
            collider.enabled = false;
        }
    }

    public void ActivateColliders()
    {
        foreach (Collider collider in _hitColliders)
        {
            collider.enabled = true;
        }
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        //Use this to ensure that the Gizmos are being drawn when in Play Mode.
        m_Started = true;
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        if (m_Started)
            Gizmos.DrawWireCube(transform.position, transform.localScale);
    }
}
