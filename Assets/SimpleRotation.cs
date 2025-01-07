using UnityEngine;

public class SimpleRotation : MonoBehaviour
{

    // Update is called once per frame
    public float Speed = 0.001f;

    void Update()
    {
        transform.Rotate(Vector3.up, Speed, Space.World);
    }
}
