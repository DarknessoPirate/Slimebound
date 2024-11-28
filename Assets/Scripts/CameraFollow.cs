using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public float followSpeed = 5f;        // player follow speed
    public Transform target;              // playere reference
    public float distance = 10f;          // distance from the player
    public float height = 5f;             // height offset from the player

    private float targetRotationY = 0f;   //  target Y rotation angle in degrees
    public bool isRotating = false;      
    private float cameraCooldown = 0;
    public bool isOnCooldown
    {
        get { return cameraCooldown > 0; }
    }

    private void Start()
    {
        // initialize target rotation with current position
        targetRotationY = transform.eulerAngles.y;
    }

    private void LateUpdate()
    {
        if (cameraCooldown > 0)
        {
            cameraCooldown -= Time.deltaTime;
            Debug.Log(cameraCooldown);
        }
        // calculate the target position based on the target rotation angle
        Quaternion targetRotation = Quaternion.Euler(0, targetRotationY, 0);
        Vector3 offset = targetRotation * new Vector3(0, height, -distance);
        Vector3 targetPosition = target.position + offset;

        // smooth movement to target position
        transform.position = Vector3.Slerp(transform.position, targetPosition, followSpeed * Time.deltaTime);

        // camera always facing the player
        transform.LookAt(target);
    }

    public void RotateCamera(float angle)
    {
        if (!isRotating)
        {
            // increment the target Y rotation by 90 degrees
            targetRotationY += angle;

            // clamp targetRotationY to keep it within 0 - 360 degrees to prevent overflow
            targetRotationY %= 360;

            // prevents more rotation inputs until the current rotation is finished
            isRotating = true;

            // apply rotation and reset isRotating after a slight delay
            Invoke("FinishRotation", 0.1f); // reset isRotating with a slight delay
        }
    }

    private void FinishRotation()
    {
        isRotating = false;
        cameraCooldown = 1f;
    }
}

