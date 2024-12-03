using UnityEngine;

public class CopyHorizontalRotation : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        gameObject.transform.rotation = Quaternion.Euler(Camera.main.transform.rotation.eulerAngles);
    }
}
