using UnityEngine;

public class GroundTeleporter : MonoBehaviour
{
    public ColliderTransformer ColliderTransformer;
    public GameObject Player;
    public float ActivationDistance = 2f;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {

    }

    private void Update()
    {
        RaycastHit hit;
        Ray ray = new Ray(transform.position, Vector3.down);
        if(Physics.SphereCast(ray,transform.localScale.x/2f - 0.05f, out hit, ActivationDistance, LayerMask.GetMask("ColliderCopy")))
        {
            RaycastHit hit2;
            if (!Player.GetComponent<PlayerController>().isGrounded && !Physics.SphereCast(ray, transform.localScale.x / 2f - 0.05f, out hit2, ActivationDistance + 0.1f, LayerMask.GetMask("Default")))
            {
                ColliderTransformer.CheckTransformedCollider(hit.collider, Player);
            }
        }
    }
}
