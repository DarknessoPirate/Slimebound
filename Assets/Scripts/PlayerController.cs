using System;
using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public InputAction move;
    public InputAction rotate;
    public InputAction jump;
    public CameraFollow cameraFollow;
    public float moveSpeed = 5f;

    private Rigidbody _rb;

    public float gravityMultiplier = 2f;
    private bool isJumping = false;
    private float jumpStartY;
    private float distanceToMaxJump;
    private Vector3 movementAxis; 
    public float groundCheckDistance = 0.1f; 
    public float ceilingCheckDistance = 0.1f; 
    public bool isGrounded = false;
    public bool isTouchingCeiling = false;

    private void Start()
    {
        move.Enable();
        rotate.Enable();
        jump.Enable();
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
        HandleRotation();

        if (jump.triggered)
        {
            jumpBufferCounter = jumpBufferTime; // reset the buffer counter if jump was triggered
            _jumpRequested = true;
        }
        else
        {
            jumpBufferCounter -= Time.deltaTime; // decrease buffer over time
        }

        if (isGrounded)
        {
            coyoteTimeCounter = coyoteTime; // reset coyote time if grounded
        }
        else
        {
            coyoteTimeCounter -= Time.deltaTime; // countdown coyote time if not grounded
        }

        if (Input.GetKeyDown(KeyCode.LeftShift) && canDash) // TODO: REPLACE WITH DASH INPUT LATER
        {
            StartCoroutine(Dash());
        }
    }

    private void FixedUpdate()
    {
        CheckGrounded();
        CheckCeilingHit();
        HandleMovement();
        HandleJump();
        ApplyGravity();
    }

    private void HandleMovement()
    {
        float horizontalInput = move.ReadValue<float>(); // -1 for A, 1 for D
        Vector3 moveDirection = movementAxis * horizontalInput * moveSpeed * Time.deltaTime;
        _rb.MovePosition(_rb.position + moveDirection);
    }

    private void ApplyGravity()
    {
        if (!isGrounded)
        {
            _rb.AddForce(Vector3.down * Physics.gravity.y * gravityMultiplier, ForceMode.Acceleration);
        }
    }

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

    private void OnDrawGizmos()
    {
        // visualize the raycasts in the editor
        Gizmos.color = Color.green;
        Gizmos.DrawLine(transform.position, transform.position + Vector3.down * groundCheckDistance);
        Gizmos.DrawLine(transform.position, transform.position + Vector3.up * ceilingCheckDistance);
    }

    private void HandleRotation()
    {
        if (cameraFollow.isReadyToRotate)
        {
            if (rotate.ReadValue<float>() > 0)
            {
                cameraFollow.RotateCamera(-90f);
                movementAxis = Quaternion.Euler(0, -90, 0) * movementAxis;

            }
            else if (rotate.ReadValue<float>() < 0)
            {
                cameraFollow.RotateCamera(90f);
                movementAxis = Quaternion.Euler(0, 90, 0) * movementAxis; // Rotate movement axis
            }
        }
    }

    #region DASHING
    bool canDash = true;
    bool isDashing;
    private float dashingPower = 10f;
    private float dashingTime = 0.2f;
    private float dashingCooldown = 1f;

    private IEnumerator Dash()
    {
        float horizontalInput = move.ReadValue<float>();
        if (horizontalInput == 0)
        {
            yield break; // exit the coroutine if no directional input
        }

        canDash = false;
        isDashing = true;
        float originalYVelocity = _rb.linearVelocity.y;
        Vector3 dashDirection = Camera.main.transform.right * horizontalInput;
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
    public float jumpForce = 5f;
    public float maxJumpHeight = 2f;
    private bool _jumpRequested = false;
    private float coyoteTimeCounter;
    private float jumpBufferCounter;
    public float coyoteTime = 0.2f;
    public float jumpBufferTime = 0.2f;
    private bool doubleJump = false;

    private void HandleJump()
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

        if (!isGrounded && doubleJump && _jumpRequested)
        {
            _rb.linearVelocity = new Vector3(_rb.linearVelocity.x, jumpForce, _rb.linearVelocity.z);
            doubleJump = false;
        }
    }
    #endregion
}