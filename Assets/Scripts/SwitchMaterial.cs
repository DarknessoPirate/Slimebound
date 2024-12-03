using UnityEngine;

public class SwitchMaterial : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    private Material _savedMaterial;
    public Material NewMaterial;
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.name == "PlayerMesh")
        {
            _savedMaterial = other.gameObject.GetComponent<Renderer>().material;
            other.gameObject.GetComponent<Renderer>().material = NewMaterial;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.name == "PlayerMesh")
        {
            other.gameObject.GetComponent<Renderer>().material = _savedMaterial;
        }
    }
}
