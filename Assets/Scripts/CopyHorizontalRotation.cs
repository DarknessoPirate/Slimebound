using UnityEngine;

public class CopyHorizontalRotation : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    [SerializeField]
    GameObject[] GameObjects;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        foreach (GameObject obj in GameObjects) 
        {
            obj.transform.rotation = Quaternion.Euler(Camera.main.transform.rotation.eulerAngles);
        }
        
        //gameObject.transform.rotation = Quaternion.Euler(Camera.main.transform.rotation.eulerAngles);
    }
}
