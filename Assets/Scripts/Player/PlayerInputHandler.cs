using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInputHandler : MonoBehaviour
{
    public InputAction move;
    public InputAction rotate;
    public InputAction jump;
    public InputAction dash;

    public event Action<float> OnMove; // Notifies PlayerController with horizontal input
    public event Action<float> OnRotate; // Notifies PlayerController with rotation input
    public event Action OnJump; // Notifies PlayerController when jump is triggered
    public event Action OnDash;

    private void OnEnable()
    {
        move.Enable();
        rotate.Enable();
        jump.Enable();
        dash.Enable();
    }

    private void OnDisable()
    {
        move.Disable();
        rotate.Disable();
        jump.Disable();
        dash.Disable();
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    private void Update()
    {
        // Raise movement event
        float moveInput = move.ReadValue<float>();
        OnMove?.Invoke(moveInput);
        // Raise rotation event
        float rotateInput = rotate.ReadValue<float>();
        if (rotateInput != 0)
        {
            OnRotate?.Invoke(rotateInput);
        }

        // Raise jump event
        if (jump.triggered)
        {
            OnJump?.Invoke();
        }

        if (dash.triggered)
        {
            OnDash?.Invoke();
        }
    }
}
