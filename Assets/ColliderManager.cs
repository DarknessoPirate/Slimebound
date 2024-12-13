using System.Collections.Generic;
using UnityEngine;

public class ColliderManager : MonoBehaviour
{
    internal class TransformedObject
    {
        public GameObject copiedObject { get; }
        public Vector3 originalPosition { get; }
        Axis axis;
        public TransformedObject(GameObject originalObject, Axis axis)
        {
            this.axis = axis;
            this.originalPosition = originalObject.transform.position;
            originalObject.layer = 0;
            copiedObject = GameObject.Instantiate(originalObject, GameObject.Find("colliderCopies").transform);
            Destroy(copiedObject.GetComponent<MeshRenderer>());
            switch (axis)
            {
                case Axis.X:
                    copiedObject.transform.localScale += new Vector3(0, 0, 300);
                    break;
                case Axis.Z:
                    copiedObject.transform.localScale += new Vector3(300, 0, 0);
                    break;
            }
            copiedObject.layer = LayerMask.NameToLayer("ColliderCopy");
            copiedObject.AddComponent<ColliderTransformerHelper>();
        }

        public void SwitchAxis(Axis newAxis)
        {
            switch (newAxis)
            {
                case Axis.X:
                    copiedObject.transform.localScale += new Vector3(300, 0, -300);
                    this.axis = Axis.Z;
                    break;
                case Axis.Z:
                    copiedObject.transform.localScale += new Vector3(-300, 0, 300);
                    this.axis = Axis.X;
                    break;
            }
        }

        public void Enable()
        {
            copiedObject.GetComponent<Collider>().enabled = true;
        }

        public void Disable()
        {
            copiedObject.GetComponent<Collider>().enabled = true;
        }

        public bool isEqual(Collider collider)
        {
            return collider == copiedObject.GetComponent<Collider>();
        }
    }

    private void _teleportPlayer(GameObject player, TransformedObject block)
    {
        switch (_transformAxis)
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
        foreach (var transformed in _detectedColliders)
        {
            if (transformed.isEqual(collider))
            {
                _teleportPlayer(player, transformed);
                break;
            }
        }
    }

    public enum Axis
    {
        X,
        Z,
    }

    public ColliderTransformer cullerPlusX;
    public ColliderTransformer cullerPlusZ;
    public ColliderTransformer cullerMinusX;
    public ColliderTransformer cullerMinusZ;
    public PlayerControllerRevamped playerController;

    private Axis _lastAxis;
    private Axis _transformAxis;
    private List<TransformedObject> _detectedColliders = new List<TransformedObject>();
    private Vector3 _lastMovementAxis = Vector3.zero;

    private Axis axisFromVector(Vector3 axis)
    {
        if (Mathf.RoundToInt(axis.x) == 1 || Mathf.RoundToInt(axis.x) == -1f)
        {
            return Axis.Z;
        } else
        {
            return Axis.X;
        }
    }

    private void updateCollidersAxis(Axis axis)
    {
        if(_detectedColliders.Capacity == 0)
        {
            return;
        }
        foreach (var collider in _detectedColliders)
        {
            collider.SwitchAxis(axis);  
            collider.copiedObject.gameObject.GetComponent<ColliderTransformerHelper>().InitCollider();
        }
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        GameObject colliderCopies = new GameObject("colliderCopies");
        var found = GameObject.FindGameObjectsWithTag("RealBlock");
        foreach(GameObject obj in found)
        {
            _detectedColliders.Add(new TransformedObject(obj, Axis.Z));
        }
        cullerMinusX.GetColliders();
        cullerPlusX.GetColliders();
        cullerPlusZ.GetColliders();
        cullerMinusZ.GetColliders();
    }

    void Update()
    {
        Vector3 movementAxis = playerController.GetMovementAxis();
        _transformAxis = axisFromVector(movementAxis);
        if(_transformAxis != _lastAxis)
        {
            _lastAxis = _transformAxis;
            updateCollidersAxis(_transformAxis);
        }

        if(_lastMovementAxis != movementAxis)
        {
            _lastMovementAxis = movementAxis;
            // cull back area based on movement axis
            if (movementAxis == Vector3.right)
            {
                cullerPlusX.ActivateColliders();
                cullerMinusX.ActivateColliders();
                cullerPlusZ.DeactiveColliders();
                cullerMinusZ.ActivateColliders();
            }
            else if (movementAxis == Vector3.left)
            {
                cullerPlusX.ActivateColliders();
                cullerMinusX.ActivateColliders();
                cullerPlusZ.ActivateColliders();
                cullerMinusZ.DeactiveColliders();
            }
            else if (movementAxis == Vector3.forward)
            {
                cullerPlusX.ActivateColliders();
                cullerMinusX.DeactiveColliders();
                cullerPlusZ.ActivateColliders();
                cullerMinusZ.ActivateColliders();
            }
            else
            {
                cullerPlusX.DeactiveColliders();
                cullerMinusX.ActivateColliders();
                cullerPlusZ.ActivateColliders();
                cullerMinusZ.ActivateColliders();
            }
        }
    }
}
