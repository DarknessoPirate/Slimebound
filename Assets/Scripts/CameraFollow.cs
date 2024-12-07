using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public float rotationSpeed = 10f;
    public float followSpeed = 5f;        // player follow speed
    public Transform target;              // playere reference
    public float distance = 10f;          // distance from the player
    public float height = 5f;             // height offset from the player

    public float targetRotationY = 90f;   //  target Y rotation angle in degrees
    public float cameraRotationEndThreshold = 0.5f;
    public bool isRotating = false;
    private float cameraCooldown = 0;
    public bool isOnCooldown
    {
        get { return cameraCooldown > 0; }
    }

    public bool isReadyToRotate
    {
        get { return !isRotating && !isOnCooldown; }
    }

    private void Start()
    {
        // initialize target rotation with current position
        targetRotationY = transform.eulerAngles.y;
    }

    private void FixedUpdate()
    {
        if (cameraCooldown > 0)
        {
            cameraCooldown -= Time.deltaTime;

        }
        // calculate the target position based on the target rotation angle
        Quaternion targetRotation = Quaternion.Euler(0, targetRotationY, 0);
        Vector3 offset = targetRotation * new Vector3(0, height, -distance);
        Vector3 targetPosition = target.position + offset;
        // distance from desired angle and current angle
        float angleDifference = Quaternion.Angle(transform.rotation, targetRotation);

        if(angleDifference > cameraRotationEndThreshold)
        {
            transform.position = Vector3.Slerp(transform.position, targetPosition, followSpeed * Time.deltaTime);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }
        else
        {
            transform.position = Vector3.Slerp(transform.position, targetPosition, followSpeed * Time.deltaTime);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }

        
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
