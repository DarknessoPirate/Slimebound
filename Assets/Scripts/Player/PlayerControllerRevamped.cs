using System;
using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerControllerRevamped : MonoBehaviour
{
    public CameraFollow cameraFollow;
    private Rigidbody _rb;
    private BoxCollider _boxCollider;
    public PlayerInputHandler inputHandler;

    [Header("Movement Settings")]
    public float moveSpeed = 5f;
    public float runAccelAmount = 11f;
    public float runDeccelAmount = 16f;
    public float maxSpeed = 8f;
    public float airAccelMultiplier = 0.5f;
    public float airDeccelMultiplier = 0.5f;

    private Vector3 movementAxis;
    private float moveDirection;

    [Header("Gravity Settings")]
    public float gravityMultiplier = 2f;
    public float fallMultiplier = 2.5f;

    [Header("Jump Settings")]
    public float jumpForce = 11f;
    public float wallJumpForce = 14f;
    private bool canDoubleJump = false;
    public float coyoteTime = 0.2f;
    public float jumpBufferTime = 0.2f;
    private bool isJumping;
    public float jumpCutMultiplier = -2f;
    public float lastGroundedTime { get; private set; }
    public float lastJumpPressedTime { get; private set; }

    [Header("Wall Settings")]
    public LayerMask wallLayer;
    public float wallSlideSpeed = 1.5f;
    public float wallJumpDirectionMultiplier = 1.5f;
    private Vector3 wallNormal;


    [Header("Dash Settings")]
    public float dashingPower = 12f;
    public float dashingTime = 0.2f;
    public float dashingCooldown = 1f;
    private bool canDash = true;
    private bool isDashing;

    [Header("Check Settings")]
    public float ceilingCheckDistance = 0.2f;
    public float groundCheckDistance = 0.2f;
    public float wallCheckDistance = 0.6f;
    float inwardOffset = 0.1f;
    public LayerMask groundLayers;
    public bool isTouchingCeiling { get; private set; }
    public bool isTouchingWall { get; private set; }
    public bool isGrounded { get; private set; }

    public bool isOnXAxis { get; private set; } = true;
    private bool m_started = false;

    private void Start()
    {
        m_started = true;
        inputHandler.OnMove += HandleMovement;
        inputHandler.OnJump += HandleJump;
        inputHandler.OnRotate += HandleRotation;
        inputHandler.OnDash += HandleDash;

        _rb = GetComponent<Rigidbody>();
        _boxCollider = GetComponent<BoxCollider>();
        movementAxis = transform.right;
    }

    private void Update()
    {
        HandleLedge();
        CheckGrounded();
        HandleTimers();
        CheckCeilingHit();
        CheckWallCollision();
        CheckPlayerVisibility();
        CheckDirectionToFace(moveDirection > 0);
    }

    private void FixedUpdate()
    {
        if (!isDashing)
        {
            ApplyGravity();
            Move();
            Jump();
        }
    }

    private void CheckPlayerVisibility()
    {
        Vector3 direction = transform.position - cameraFollow.transform.position;
        RaycastHit hit;
        int pillarLayer = LayerMask.NameToLayer("Pillar");
        int playerLayer = LayerMask.NameToLayer("Player");
        int defaultLayer = LayerMask.NameToLayer("Default");

        // Create a layer mask that includes "Pillar", "Player", and "Default"
        int layerMask = (1 << pillarLayer) | (1 << playerLayer) | (1 << defaultLayer);

        // Perform the raycast
        if (Physics.Raycast(cameraFollow.transform.position, direction, out hit, direction.magnitude + 10f, layerMask))
        {
            if(hit.collider.tag == "Player")
            {
                inputHandler.EnabledInputs = true;
            } else
            {
                _rb.linearVelocity = new Vector3(0f, _rb.linearVelocity.y, 0f);
                inputHandler.EnabledInputs = false;
            }
            Debug.DrawLine(cameraFollow.transform.position, hit.point, Color.green);
        }
    }

    private void HandleLedge()
    {
        if (!isGrounded && _rb.linearVelocity.magnitude < 0.01f) // Is stuck on the ledge (stuck in air)
        {
            _rb.AddForce(wallNormal * Physics.gravity.y * (gravityMultiplier - 1), ForceMode.Acceleration);
        }
    }

    private void HandleMovement(float value)
    {
        moveDirection = value;
    }

    private void HandleJump()
    {
        lastJumpPressedTime = jumpBufferTime;
    }

    private void HandleDash()
    {
        if (canDash)
        {
            StartCoroutine(Dash());
        }
    }

    private void HandleRotation(float value)
    {
        if (cameraFollow.isReadyToRotate)
        {
            if (value > 0)
            {
                cameraFollow.RotateCamera(-90f);
                movementAxis = Quaternion.Euler(0, -90, 0) * movementAxis;
                isOnXAxis = !isOnXAxis;

            }
            else if (value < 0)
            {
                cameraFollow.RotateCamera(90f);
                movementAxis = Quaternion.Euler(0, 90, 0) * movementAxis; // Rotate movement axis
                isOnXAxis = !isOnXAxis;
            }
        }
    }

    private IEnumerator Dash()
    {
        canDash = false;
        isDashing = true;

        Vector3 dashDirection = movementAxis * moveDirection;
        _rb.linearVelocity = dashDirection.normalized * dashingPower;

        yield return new WaitForSeconds(dashingTime);
        isDashing = false;

        yield return new WaitForSeconds(dashingCooldown);
        canDash = true;
    }

    private void HandleTimers()
    {
        lastGroundedTime -= Time.deltaTime;
        lastJumpPressedTime -= Time.deltaTime;

        if (isGrounded)
        {
            lastGroundedTime = coyoteTime;
            isJumping = false;
            canDoubleJump = false;
        }
    }

    private void Move()
    {
        // Calculate the target velocity along the movement axis
        Vector3 targetVelocity = movementAxis * moveDirection * maxSpeed;

        // Preserve the current Y velocity to avoid interfering with jumping
        targetVelocity.y = _rb.linearVelocity.y;

        // Calculate the difference between the current velocity and target velocity
        Vector3 velocityDifference = targetVelocity - _rb.linearVelocity;

        // Adjust acceleration rate based on grounded state
        float accelRate = moveDirection != 0
            ? (lastGroundedTime > 0 ? runAccelAmount : runAccelAmount * airAccelMultiplier)
            : (lastGroundedTime > 0 ? runDeccelAmount : runDeccelAmount * airDeccelMultiplier);

        // Apply movement force along the movement axis
        Vector3 movementForce = velocityDifference * accelRate;
        _rb.AddForce(movementForce, ForceMode.Acceleration);


    }

    private void Jump()
    {
        if (CanWallJump() && lastJumpPressedTime > 0)
        {
            Vector3 jumpDir = (wallNormal + Vector3.up * wallJumpDirectionMultiplier).normalized;
            _rb.linearVelocity = jumpDir * wallJumpForce;
            isJumping = true;
            lastJumpPressedTime = 0; // Consume jump input
            return;

        }
        else if (CanJump() && lastJumpPressedTime > 0)
        {
            _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, jumpForce, _rb.linearVelocity.z);
            isJumping = true;
            lastJumpPressedTime = 0;
            canDoubleJump = true;
        }
        else if (CanDoubleJump() && lastJumpPressedTime > 0)
        {
            _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, jumpForce, _rb.linearVelocity.z);
            isJumping = true;
            lastJumpPressedTime = 0;
            canDoubleJump = false;
        }

    }

    private void ApplyGravity()
    {
        if (_rb.linearVelocity.y < 0)
        {
            _rb.AddForce(Vector3.down * Physics.gravity.y * (fallMultiplier - 1), ForceMode.Acceleration);
        }
        else if (_rb.linearVelocity.y > 0 && !isJumping)
        {
            _rb.AddForce(Vector3.down * Physics.gravity.y * (jumpCutMultiplier - 1), ForceMode.Acceleration);
        }
        else
        {
            _rb.AddForce(Vector3.down * Physics.gravity.y * (gravityMultiplier - 1), ForceMode.Acceleration);
        }

        if (isTouchingWall && _rb.linearVelocity.y < -wallSlideSpeed)
        {
            _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, -wallSlideSpeed, _rb.linearVelocity.z);
        }
    }

    private void CheckCeilingHit()
    {
        Vector3 colliderBounds = _boxCollider.bounds.extents;

        // Ceiling rays
        Vector3 leftRayOrigin = transform.TransformPoint(_boxCollider.center) +
                                    transform.right * _boxCollider.size.x / 2.05f +
                                    Vector3.up * (colliderBounds.y - inwardOffset);
        Vector3 rightRayOrigin = transform.TransformPoint(_boxCollider.center) +
                                -1 * transform.right * _boxCollider.size.x / 2.05f +
                                Vector3.up * (colliderBounds.y - inwardOffset);

        RaycastHit hit;
        isTouchingCeiling = Physics.Raycast(leftRayOrigin, Vector3.up, out hit, ceilingCheckDistance) ||
                            Physics.Raycast(rightRayOrigin, Vector3.up, out hit, ceilingCheckDistance);

        if (isTouchingCeiling && _rb.linearVelocity.y > 0)
        {
            _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, 0, _rb.linearVelocity.z);
        }
    }

    private void CheckWallCollision()
    {
        Vector3 colliderBounds = _boxCollider.bounds.extents;

        // Wall rays centered along the Z-axis
        Vector3 topRayOrigin = transform.TransformPoint(_boxCollider.center) +
                                Vector3.up * (_boxCollider.size.y / 2 - inwardOffset);
        Vector3 bottomRayOrigin = transform.position + _boxCollider.center +
                                Vector3.down * (_boxCollider.size.y / 2 - inwardOffset);

        RaycastHit hit;
        isTouchingWall = false;

        // Cast ray in both directions (right and left)
        Vector3[] directions = { movementAxis.normalized, -movementAxis.normalized };

        foreach (var direction in directions)
        {
            if (Physics.Raycast(topRayOrigin, direction, out hit, wallCheckDistance, wallLayer) ||
                Physics.Raycast(bottomRayOrigin, direction, out hit, wallCheckDistance, wallLayer))
            {
                isTouchingWall = true;
                wallNormal = hit.normal; // Save the wall's normal
                break; // Stop checking after the first hit
            }
        }
    }

    private void CheckGrounded()
    {
        // Get the bounds of the box collider
        Vector3 colliderBounds = _boxCollider.bounds.extents;

        // Determine the start and end positions for the ground rays
        Vector3 leftRayOrigin = transform.TransformPoint(_boxCollider.center) +
                                   transform.right * _boxCollider.size.x / 2.05f -
                                   Vector3.up * (colliderBounds.y - inwardOffset);

        Vector3 rightRayOrigin = transform.TransformPoint(_boxCollider.center) +
                                -1 * transform.right * _boxCollider.size.x / 2.05f -
                                Vector3.up * (colliderBounds.y - inwardOffset);
        isGrounded = Physics.Raycast(leftRayOrigin, Vector3.down, groundCheckDistance) || Physics.Raycast(rightRayOrigin, Vector3.down, groundCheckDistance);
    }

    private bool CanJump()
    {
        return lastGroundedTime > 0 && !isJumping;
    }

    private bool CanWallJump()
    {
        return isTouchingWall && !isGrounded;
    }

    private bool CanDoubleJump()
    {
        return canDoubleJump && !isTouchingWall && isJumping;
    }


    private void CheckDirectionToFace(bool isMovingRight)
    {
        if (isMovingRight && transform.localScale.x < 0 || !isMovingRight && transform.localScale.x > 0)
        {
            Vector3 scale = transform.localScale;
            scale.x *= -1;
            transform.localScale = scale;
        }
    }

 
    private void OnDrawGizmosSelected()
    {
        if(m_started)
        {
            Vector3 colliderBounds = _boxCollider.bounds.extents;
            
            // Ground check rays
            Vector3 leftGroundRay = transform.TransformPoint(_boxCollider.center) +
                                    transform.right * _boxCollider.size.x / 2.05f - 
                                    Vector3.up * (colliderBounds.y - inwardOffset);

            Vector3 rightGroundRay = transform.TransformPoint(_boxCollider.center) +
                                    -1 * transform.right * _boxCollider.size.x / 2.05f - 
                                    Vector3.up * (colliderBounds.y - inwardOffset);

            Gizmos.color = Color.green;
            Gizmos.DrawLine(leftGroundRay, leftGroundRay + Vector3.down * groundCheckDistance);
            Gizmos.DrawLine(rightGroundRay, rightGroundRay + Vector3.down * groundCheckDistance);

            // Ceiling check rays
            Vector3 leftCeilingRayOrigin = transform.TransformPoint(_boxCollider.center) +
                                    transform.right * _boxCollider.size.x / 2.05f + 
                                    Vector3.up * (colliderBounds.y - inwardOffset);
            Vector3 rightCeilingRayOrigin = transform.TransformPoint(_boxCollider.center) +
                                    -1 * transform.right * _boxCollider.size.x / 2.05f + 
                                    Vector3.up * (colliderBounds.y - inwardOffset);

            Gizmos.color = Color.blue;
            Gizmos.DrawLine(leftCeilingRayOrigin, leftCeilingRayOrigin + Vector3.up * ceilingCheckDistance);
            Gizmos.DrawLine(rightCeilingRayOrigin, rightCeilingRayOrigin + Vector3.up * ceilingCheckDistance);

            // Wall check rays centered along Z-axis
            Vector3 topWallRayOrigin = transform.TransformPoint(_boxCollider.center) +
                                    Vector3.up * (_boxCollider.size.y/2 - inwardOffset);
            Vector3 bottomWallRayOrigin = transform.position + _boxCollider.center +
                                    Vector3.down * (_boxCollider.size.y/2 - inwardOffset);
   

            Gizmos.color = Color.red;
            Gizmos.DrawLine(topWallRayOrigin, topWallRayOrigin + transform.right * wallCheckDistance);
            Gizmos.DrawLine(bottomWallRayOrigin, bottomWallRayOrigin + transform.right * wallCheckDistance);
            Gizmos.DrawLine(topWallRayOrigin, topWallRayOrigin - transform.right * wallCheckDistance);
            Gizmos.DrawLine(bottomWallRayOrigin, bottomWallRayOrigin - transform.right * wallCheckDistance);
        }
    }

    public Vector3 GetMovementAxis()
    {
        return movementAxis;
    }
}
