using System.Collections.Generic;
using UnityEngine;

public class ColliderTransformer : MonoBehaviour
{
    private bool m_Started;
    private Collider[] hitColliders;

    public void GetColliders()
    {
        hitColliders = Physics.OverlapBox(gameObject.transform.position, transform.localScale / 2, Quaternion.identity, ~(LayerMask.NameToLayer("ColliderCopy")));
    }

    public void DeactiveColliders()
    {
        foreach (Collider collider in hitColliders)
        {
            collider.enabled = false;
        }
    }

    public void ActivateColliders()
    {
        foreach (Collider collider in hitColliders)
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

    //Draw the Box Overlap as a gizmo to show where it currently is testing. Click the Gizmos button to see this
    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        //Check that it is being run in Play Mode, so it doesn't try to draw this in Editor mode
        if (m_Started)
            //Draw a cube where the OverlapBox is (positioned where your GameObject is as well as a size)
            Gizmos.DrawWireCube(transform.position, transform.localScale);
    }
}
