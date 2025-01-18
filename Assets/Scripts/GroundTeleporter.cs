using UnityEngine;

public class GroundTeleporter : MonoBehaviour
{
    public ColliderManager ColliderManager;
    public GameObject Player;
    public float ActivationDistance = 2f;
    public float DistanceFromPillar = 0.03f;
    public float BehindPillarDistanceDetection = 0.45f;
    private BoxCollider _pillarBoxCollider;
    private PlayerControllerRevamped _playerControllerRevamped;

    private void Start()
    {
        _pillarBoxCollider = GameObject.Find("Pillar").GetComponent<BoxCollider>();
        _playerControllerRevamped = Player.GetComponent<PlayerControllerRevamped>();
    }

    private void teleportPlayerToFront(Vector3 hitNormal)
    {
        if (hitNormal == Vector3.back)
        {
            Player.transform.position = new Vector3(transform.position.x, transform.position.y, _pillarBoxCollider.bounds.max.z + 0.7f); //good
        }
        else if (hitNormal == Vector3.forward)
        {
            Player.transform.position = new Vector3(transform.position.x, transform.position.y, _pillarBoxCollider.bounds.max.z - 0.7f); //good
        }
        else if (hitNormal == Vector3.left)
        {
            Player.transform.position = new Vector3(_pillarBoxCollider.bounds.max.x + 0.7f, transform.position.y, transform.position.z);
        }
        else
        {
            Player.transform.position = new Vector3(_pillarBoxCollider.bounds.min.x - 0.7f, transform.position.y, transform.position.z);
        }
    }

    //CHECK FOR: Player is above pillar's top point and might need to be teleported towards it.
    private void checkPlayerAbovePillar()
    {
        if (Player.GetComponent<BoxCollider>().bounds.min.y <= _pillarBoxCollider.bounds.max.y || Camera.main.GetComponent<CameraFollow>().isRotating)
        {
            return;
        }

        var distinguishedAxis = _playerControllerRevamped.GetMovementAxis().normalized;
        Vector3 rayCastOrigin;
        Vector3 upOffset = new Vector3(0, 0f, 0);

        if (Mathf.Abs(distinguishedAxis.x) == 1)
        {
            if (Player.transform.position.z == _pillarBoxCollider.transform.position.z)
            {
                return;
            }
            rayCastOrigin = new Vector3(Player.transform.position.x, Player.transform.position.y, _pillarBoxCollider.transform.position.z);
        } else
        {
            if (Player.transform.position.x == _pillarBoxCollider.transform.position.x)
            {
                return;
            }
            rayCastOrigin = new Vector3(_pillarBoxCollider.transform.position.x, Player.transform.position.y, Player.transform.position.z);
        }

        Debug.DrawRay(rayCastOrigin + upOffset, Vector3.down, Color.magenta);

        if(Physics.Raycast(rayCastOrigin + upOffset, Vector3.down, 20f, 1 << LayerMask.NameToLayer("Pillar"))) {
            Player.transform.position = rayCastOrigin;
        }
    }

    // CHECK FOR: Player is trying to get behind the pillar and hide behind camera
    private void checkPlayerVisibility()
    {
        if (Camera.main.GetComponent<CameraFollow>().isRotating)
        {
            return;
        }
        RaycastHit hit;

        Debug.DrawRay(transform.position + transform.right * BehindPillarDistanceDetection, -transform.forward);
        Debug.DrawRay(transform.position - transform.right * BehindPillarDistanceDetection, -transform.forward);

        // Perform the raycast
        if (Physics.Raycast(transform.position + transform.right * BehindPillarDistanceDetection, -transform.forward, out hit, ((transform.position - Camera.main.transform.position) * 2).magnitude, LayerMask.GetMask("Pillar"))            )
        {
            teleportPlayerToFront(hit.normal);
        }
        else if 
            (
            Physics.Raycast(transform.position - transform.right * BehindPillarDistanceDetection, -transform.forward, out hit, ((transform.position - Camera.main.transform.position) * 2).magnitude, LayerMask.GetMask("Pillar"))
            )
        {
            teleportPlayerToFront(hit.normal);
        }
    }

    // CHECK FOR: Teleport player to the ColliderCopy block under his feet
    private void checkGround()
    {
        RaycastHit hit;
        Ray ray = new Ray(transform.position, Vector3.down);
        if(Physics.SphereCast(ray, Mathf.Abs(transform.localScale.x)/2f - 0.05f, out hit, ActivationDistance, LayerMask.GetMask("ColliderCopy")))
        {
            RaycastHit hit2;
            if (!Physics.SphereCast(ray, transform.localScale.x / 2f - 0.05f, out hit2, ActivationDistance + 0.1f, LayerMask.GetMask("Default")))
            {
                ColliderManager.CheckTransformedCollider(hit.collider, Player);
                
            }
        }
    }

    // CHECK FOR: Pillar is either on left or right side of the player case
    private void checkLeftRightPillar()
    {
        RaycastHit hit;
        Ray rayRight = new Ray(transform.position, GetComponent<PlayerControllerRevamped>().GetMovementAxis().normalized);
        Ray rayLeft = new Ray(transform.position, -GetComponent<PlayerControllerRevamped>().GetMovementAxis().normalized);
        if (Camera.main.GetComponent<CameraFollow>().isRotating)
        {
            return;
        }
        if (
             Physics.Raycast(rayLeft, out hit, gameObject.GetComponent<BoxCollider>().size.x / 2f + DistanceFromPillar, LayerMask.GetMask("Pillar"))
           )
        {
            Vector3 pillarNormal = hit.normal;
            if (pillarNormal == Vector3.right)
            {
                Player.transform.position = new Vector3(transform.position.x, transform.position.y, _pillarBoxCollider.bounds.min.z - 0.7f);
            }
            else if (pillarNormal == Vector3.left)
            {
                Player.transform.position = new Vector3(transform.position.x, transform.position.y, _pillarBoxCollider.bounds.max.z + 0.7f);
            }
            else if (pillarNormal == Vector3.forward)
            {
                Player.transform.position = new Vector3(_pillarBoxCollider.bounds.max.x + 0.7f, transform.position.y, transform.position.z);
            }
            else
            {
                Player.transform.position = new Vector3(_pillarBoxCollider.bounds.min.x - 0.7f, transform.position.y, transform.position.z);
            }
        }
        else if (
            Physics.Raycast(rayRight, out hit, gameObject.GetComponent<BoxCollider>().size.x / 2f + DistanceFromPillar, LayerMask.GetMask("Pillar"))
            )
        {
            Vector3 pillarNormal = hit.normal;
            if (pillarNormal == Vector3.right)
            {
                Player.transform.position = new Vector3(transform.position.x, transform.position.y, _pillarBoxCollider.bounds.max.z + 0.7f);
            }
            else if (pillarNormal == Vector3.left)
            {
                Player.transform.position = new Vector3(transform.position.x, transform.position.y, _pillarBoxCollider.bounds.min.z - 0.7f);
            }
            else if (pillarNormal == Vector3.forward)
            {
                Player.transform.position = new Vector3(_pillarBoxCollider.bounds.min.x - 0.7f, transform.position.y, transform.position.z);
            }
            else
            {
                Player.transform.position = new Vector3(_pillarBoxCollider.bounds.max.x + 0.7f, transform.position.y, transform.position.z);
            }
        }
    }

    private void FixedUpdate()
    {
        // CHECK FOR: Teleport player to the ColliderCopy block under his feet
        checkGround();

        // CHECK FOR: Player is trying to get behind the pillar and hide behind camera
        checkPlayerVisibility();

        // CHECK FOR: Pillar is either on left or right side of the player case
        checkLeftRightPillar();

        //CHECK FOR: Player is above pillar's top point and might need to be teleported towards it.
        checkPlayerAbovePillar();
    }
}
