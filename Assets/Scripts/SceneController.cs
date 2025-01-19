using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneController : MonoBehaviour
{
    [SerializeField] Animator transitionAnim;

    public void GoToScene(int index)
    {
        StartCoroutine(LoadScene(index));
    }

    public void GoToExit()
    {
        StartCoroutine(ExitGame());
    }

    IEnumerator LoadScene(int index)
    {
        transitionAnim.SetTrigger("Start");
        yield return new WaitForSeconds(1);
        SceneManager.LoadSceneAsync(index);
    }

    IEnumerator ExitGame()
    {
        transitionAnim.SetTrigger("Start");
        yield return new WaitForSeconds(1);
        Application.Quit();
    }
}
