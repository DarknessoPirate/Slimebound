using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Abyss : MonoBehaviour
{
    [SerializeField] GameObject backToPoint;
    [SerializeField] SceneController controller;
    [SerializeField] Animator transitionAnim;

    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Player"))
        {
            controller.GoToScene(SceneManager.GetActiveScene().buildIndex);
        }
    }

    IEnumerator Transition(Collider collider)
    {
        transitionAnim.SetTrigger("Start");
        yield return new WaitForSeconds(1);
        transitionAnim.SetTrigger("End");
        collider.transform.position = backToPoint.transform.position;
    }
}
