using UnityEngine;

public class SkyRotation : MonoBehaviour
{
    public PlayerControllerRevamped PlayerController;
    public Material SkyMaterial;
    public float Speed = 0.2f;

    // Update is called once per frame
    void Update()
    {
        if (Mathf.Abs(PlayerController.GetMovementAxis().normalized.x) == 1f)
        {
            SkyMaterial.SetFloat("_Rotation", PlayerController.transform.position.x * Speed);
        }
    }
}
