using System;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public CameraFollow cameraFollow;
    private Rigidbody _rb;
    public PlayerInputHandler inputHandler;


    [Header("Movement Settings")]
    public float moveSpeed = 5f;
    private Vector3 movementAxis;
    private float moveDirection = 0f;

    [Header("Gravity Settings")]
    public float gravityMultiplier = 2f;


    private void Start()
    {
        inputHandler.OnMove += HandleMovement;
        inputHandler.OnJump += HandleJump;
        inputHandler.OnRotate += HandleRotation;
        inputHandler.OnDash += HandleDash;


        _rb = GetComponent<Rigidbody>();

        if (_rb != null)
        {
            movementAxis = _rb.transform.right;
        }

        // adjust ray distances based on sphere collider radius
        SphereCollider sphereCollider = GetComponent<SphereCollider>();
        if (sphereCollider != null)
        {
            groundCheckDistance = sphereCollider.radius + 0.05f; // extend a bit beyond radius
            ceilingCheckDistance = sphereCollider.radius + 0.1f;
        }
    }

    private void Update()
    {

        if (isGrounded)
        {
            coyoteTimeCounter = coyoteTime; // reset coyote time if grounded
        }
        else
        {
            coyoteTimeCounter -= Time.deltaTime; // countdown coyote time if not grounded
            jumpBufferCounter -= Time.deltaTime;
        }

    }


    private void FixedUpdate()
    {
        CheckGrounded();
        CheckCeilingHit();
        CheckWallCollision();
        Move();
        Jump();
        ApplyGravity();
    }

    private void HandleMovement(float value)
    {
        moveDirection = value;
    }

    private void Move()
    {
        Vector3 movement;

        if (isGrounded)
            movement = movementAxis * moveDirection * moveSpeed * Time.deltaTime;
        else
            movement = movementAxis * moveDirection * moveSpeed * Time.deltaTime;
        
        _rb.MovePosition(_rb.position + movement);
    }


    private void HandleRotation(float value)
    {
        if (cameraFollow.isReadyToRotate)
        {
            if (value > 0)
            {
                cameraFollow.RotateCamera(-90f);
                movementAxis = Quaternion.Euler(0, -90, 0) * movementAxis;

            }
            else if (value < 0)
            {
                cameraFollow.RotateCamera(90f);
                movementAxis = Quaternion.Euler(0, 90, 0) * movementAxis; // Rotate movement axis
            }
        }
    }

    private void ApplyGravity()
    {
        if (!isGrounded)
        {
            if (isTouchingWall && _rb.linearVelocity.y < 0)
            {
                _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, -wallSlideSpeed, _rb.linearVelocity.z);
            }
            else
            {
                _rb.AddForce(Vector3.down * Physics.gravity.y * gravityMultiplier, ForceMode.Acceleration);
            }
        }
    }

    #region COLLISION CHECKS

    [Header("Collisions")]
    public float groundCheckDistance = 0.1f;
    public float ceilingCheckDistance = 0.1f;
    public float wallCheckDistance = 0.5f;

    public bool isGrounded { get; private set; }
    public bool isTouchingCeiling { get; private set; }
    public bool isTouchingWall { get; private set; }

    private void CheckCeilingHit()
    {
        // cast a ray up from the sphere's center to detect a ceiling
        isTouchingCeiling = Physics.Raycast(transform.position, Vector3.up, ceilingCheckDistance);

        // stop upward velocity if the player is hitting the ceiling
        if (isTouchingCeiling && _rb.linearVelocity.y > 0)
        {
            _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, 0, _rb.linearVelocity.z);
        }
    }

    private void CheckGrounded()
    {
        // cast a ray down from the sphere's center to detect the ground
        isGrounded = Physics.Raycast(transform.position, Vector3.down, groundCheckDistance);
    }

    [Header("Wall Settings")]
  
    public LayerMask wallLayer;
    public float wallSlideSpeed = 2f;
    private Vector3 wallNormal;

    private void CheckWallCollision()
    {
        RaycastHit hit;
        isTouchingWall = false;

        // Cast ray in both directions (right and left)
        Vector3[] directions = { movementAxis.normalized, -movementAxis.normalized };

        foreach (var direction in directions)
        {
            if (Physics.Raycast(transform.position, direction, out hit, wallCheckDistance, wallLayer))
            {
                isTouchingWall = true;
                wallNormal = hit.normal; // Save the wall's normal
                break; // Stop checking after the first hit
            }
        }
    }

    #endregion   

    #region DASHING

    [Header("Dash Settings")]
    public float dashingPower = 10f;
    public float dashingTime = 0.2f;
    public float dashingCooldown = 1f;

    private bool canDash = true;
    private bool isDashing;

    private void HandleDash()
    {
        Debug.Log("Dash triggered");
        if (canDash)
        {
            StartCoroutine(Dash());
        }
    }

    private IEnumerator Dash()
    {
        
        if (moveDirection == 0)
        {
            yield break; // exit the coroutine if no directional input
        }

        canDash = false;
        isDashing = true;
        float originalYVelocity = _rb.linearVelocity.y;
        Vector3 dashDirection = Camera.main.transform.right * moveDirection;
        _rb.linearVelocity = new Vector3(
            dashDirection.normalized.x * dashingPower,
            originalYVelocity,
            dashDirection.normalized.z * dashingPower
        );

        yield return new WaitForSeconds(dashingTime);
        isDashing = false;
        _rb.linearVelocity = Vector3.zero;

        yield return new WaitForSeconds(dashingCooldown);
        canDash = true;
    }
    #endregion

    #region JUMPING 

    [Header("Jump Settings")]
    public float jumpForce = 5f;
    public float wallJumpForce = 7f;
    public float maxJumpHeight = 2f;

    public float coyoteTime = 0.2f;
    public float jumpBufferTime = 0.2f;

    private bool isJumping = false;
    private float jumpStartY;
    private float distanceToMaxJump;
    private float coyoteTimeCounter;
    private float jumpBufferCounter;
    private bool _jumpRequested;
    private bool doubleJump;
    public Vector3 wallJumpDirection = new Vector3(-1, 1, 0); // Default direction (diagonal away from wall)

    private void HandleJump()
    {
        jumpBufferCounter = jumpBufferTime;
        _jumpRequested = true;
    }

    private void Jump()
    {
        if ((jumpBufferCounter > 0 && (isGrounded || coyoteTimeCounter > 0)) && _jumpRequested)
        {
            _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, jumpForce, _rb.linearVelocity.z);
            doubleJump = true;
            isJumping = true;
            _jumpRequested = false;
            jumpStartY = transform.position.y;
            jumpBufferCounter = 0;
        }
        else if (_jumpRequested && isTouchingWall) // Wall Jump
        {
            Vector3 jumpDir = (wallNormal + Vector3.up).normalized; // Jump away from the wall
            _rb.linearVelocity = jumpDir * wallJumpForce;
            doubleJump = false;
            isJumping = true;
            _jumpRequested = false;
        }

        if (!isGrounded && doubleJump && _jumpRequested)
        {
            _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, jumpForce, _rb.linearVelocity.z);
            doubleJump = false;
            _jumpRequested = false;
        }
    }
    #endregion

    private void OnDrawGizmos()
    {
        // visualize the raycasts in the editor
        Gizmos.color = Color.green;
        Gizmos.DrawLine(transform.position, transform.position + Vector3.down * groundCheckDistance);
        Gizmos.DrawLine(transform.position, transform.position + Vector3.up * ceilingCheckDistance);
    }
}