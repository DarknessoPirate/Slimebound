using System.Collections.Generic;
using UnityEngine;

public class ColliderTransformer : MonoBehaviour
{
    internal class TransformedObject
    {
        GameObject copiedObjectSide1 { get; }
        public Vector3 originalPosition { get; }
        Axis axis;
        public TransformedObject(GameObject originalObject, Axis axis)
        {
            this.axis = axis;
            this.originalPosition = originalObject.transform.position;
            originalObject.layer = 0;
            copiedObjectSide1 = GameObject.Instantiate(originalObject, GameObject.Find("colliderCopies").transform);
            Destroy(copiedObjectSide1.GetComponent<MeshRenderer>());
            switch (axis)
            {
                case Axis.X:
                    copiedObjectSide1.transform.localScale += new Vector3(300, 0, 0);
                    break;
                case Axis.Z:
                    copiedObjectSide1.transform.localScale += new Vector3(0, 0, 300);
                    break;
            }
            copiedObjectSide1.layer = LayerMask.NameToLayer("ColliderCopy");
            SwitchColliders();
        }

        public void SwitchColliders()
        {
            copiedObjectSide1.GetComponent<Collider>().enabled = !copiedObjectSide1.GetComponent<Collider>().enabled;
        }
        public void SwitchAxis(Axis newAxis)
        {
            switch (newAxis)
            {
                case Axis.X:
                    copiedObjectSide1.transform.localScale += new Vector3(300, 0, -300);
                    this.axis = Axis.Z;
                    break;
                case Axis.Z:
                    copiedObjectSide1.transform.localScale += new Vector3(-300, 0, 300);
                    this.axis = Axis.X;
                    break;
            }
        }

        public bool isEqual(Collider collider)
        {
            return collider == copiedObjectSide1.GetComponent<Collider>();
        }
    }

    public enum Axis
    {
        X,
        Z,
    }

    public Axis transformAxis;

    // Activate transformed colliders
    public bool activateColliders = false;

    private List<TransformedObject> _detectedColliders = new List<TransformedObject>();
    private bool _doItOnce = true;
    private Axis _lastAxis;
    bool m_Started;

    private void _teleportPlayer(GameObject player, TransformedObject block)
    {
        switch (transformAxis)
        {
            case Axis.X:
                player.transform.position = new Vector3(block.originalPosition.x, player.transform.position.y, player.transform.position.z);
                break;
            case Axis.Z:
                player.transform.position = new Vector3(player.transform.position.x, player.transform.position.y, block.originalPosition.z);
                break;
        }
    }

    public void CheckTransformedCollider(Collider collider, GameObject player)
    {
        foreach (var transformed in _detectedColliders) {
            if(transformed.isEqual(collider))
            {
                _teleportPlayer(player, transformed);
                break;
            }
        }
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        _lastAxis = transformAxis;
        GameObject colliderCopies = new GameObject("colliderCopies");
        //Use this to ensure that the Gizmos are being drawn when in Play Mode.
        m_Started = true;
        Collider[] hitColliders = Physics.OverlapBox(gameObject.transform.position, transform.localScale / 2, Quaternion.identity);
        foreach (Collider col in hitColliders)
        {
            if (col.gameObject.layer == LayerMask.NameToLayer("ColliderGrabbing"))
            {
                _detectedColliders.Add(new TransformedObject(col.gameObject, transformAxis));
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        if(transformAxis != _lastAxis)
        {
            foreach (var collider in _detectedColliders)
            {
                collider.SwitchAxis(transformAxis);
            }
            _lastAxis = transformAxis;
        }

        if (activateColliders && _doItOnce)
        {
            _doItOnce = false;
            foreach (var collider in _detectedColliders)
            {
                collider.SwitchColliders();
            }
        }
        else if(!activateColliders && !_doItOnce)
        {
            _doItOnce = true;
            foreach(var collider in _detectedColliders)
            {
                collider.SwitchColliders();
            }
        }
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
