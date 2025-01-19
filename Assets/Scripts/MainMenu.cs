using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    [SerializeField] SceneController controller;
    bool isClick = false;

    public void PlayGame()
    {
        if (!isClick)
            controller.GoToScene(1);
    }

    public void QuitGame()
    {
        if (!isClick)
            controller.GoToExit();
    }
}
