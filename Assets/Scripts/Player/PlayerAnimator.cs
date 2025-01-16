using System.Linq.Expressions;
using System.Security.Cryptography.X509Certificates;
using UnityEngine;

public class PlayerAnimator : MonoBehaviour
{
    Rigidbody rigidbody;
    PlayerControllerRevamped playerControllerRevamped;
    Animator animator;

    string currentState;

    const string playerIdle = "Idle";
    const string playerStartJump = "StartJump";
    const string playerJump = "Jump";
    const string playerRaise = "Raise";
    const string playerFall = "Fall";
    const string playerEndFall = "EndFall";
    const string playerHitch = "Hitch";
    const string playerStartHitch = "StartHitch";

    [SerializeField] bool isRise = false;
    [SerializeField] bool isEndFall = false;
    [SerializeField] bool isStartHitch = false;

    void Awake()
    {
        currentState = "Idle";
        rigidbody = GetComponentInParent<Rigidbody>();
        animator = GetComponent<Animator>();
        playerControllerRevamped = GetComponentInParent<PlayerControllerRevamped>();
    }

    void Update()
    {
        AnimatorStateInfo stateInfo = animator.GetCurrentAnimatorStateInfo(0);

        if (playerControllerRevamped.isGrounded)
        {
            isRise = true;
            if (isEndFall)
            {
                ChangeAnimationState(playerEndFall);
                isEndFall = false;
            } 
            else if (!isAnimationPlaying(playerEndFall))
            {
                ChangeAnimationState(playerIdle);
            }
                
        }
        else if(playerControllerRevamped.isTouchingWall)
        {
            isRise = true;
            if (isStartHitch)
            {
                ChangeAnimationState(playerStartHitch);
                isStartHitch = false;
            }
            else if(!isAnimationPlaying(playerStartHitch))
            {
                ChangeAnimationState(playerHitch);
            }
        }
        else
        {
            isEndFall = true;
            isStartHitch = true;
            if(rigidbody.linearVelocity.y > Mathf.Epsilon)
            {
                isRise = true;
                if (currentState == playerIdle)
                    ChangeAnimationState(playerStartJump);
                else if(!isAnimationPlaying(playerStartJump))
                    ChangeAnimationState(playerJump);
            }
            else if (rigidbody.linearVelocity.y <= Mathf.Epsilon)
            {
                if(isRise)
                {
                    ChangeAnimationState(playerRaise);
                    isRise = false;
                }
                else if(!isAnimationPlaying(playerRaise))
                {
                    ChangeAnimationState(playerFall);
                }          
            }
        }
    }


    void ChangeAnimationState(string newState)
    {
        if (currentState == newState) return;

        animator.Play(newState);

        currentState = newState;
    }

    bool isAnimationPlaying(string stateName)
    {
        if(animator.GetCurrentAnimatorStateInfo(0).IsName(stateName) && 
            animator.GetCurrentAnimatorStateInfo(0).normalizedTime < 1.0f)
            return true;
        return false;
    }

    bool isAnyAnimationPlaying()
    {
        if (animator.GetCurrentAnimatorStateInfo(0).normalizedTime < 1.0f)
            return true;
        return false;
    }
}
