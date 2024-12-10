using System.Linq.Expressions;
using UnityEngine;

public class PlayerAnimator : MonoBehaviour
{
    Rigidbody rigidbody;
    Animator animator;
    string currentState;

    const string playerIdle = "Idle";
    const string playerStartJump = "StartJump";
    const string playerJump = "Jump";
    const string playerRaise = "Raise";
    const string playerEndFall = "EndFall";

    void Awake()
    {
        currentState = "Idle";
        rigidbody = GetComponentInParent<Rigidbody>();
        animator = GetComponent<Animator>();
    }

    void Update()
    {
        if(rigidbody.linearVelocity.y > 0)
        {
            ChangeAnimationState(playerJump);
        }
        else
        {
            ChangeAnimationState(playerIdle);
        }
    }


    void ChangeAnimationState(string newState)
    {
        if (currentState == newState) return;

        animator.Play(newState);

        currentState = newState;
    }
}
