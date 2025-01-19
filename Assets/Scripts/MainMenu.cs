using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    [SerializeField] SceneController controller;
    bool isClick = false;

    public void PlayGame()
    {
        if (!isClick)
        {
            isClick = true;
            controller.GoToScene(1);
        }
            
    }

    public void QuitGame()
    {
        if (!isClick)
        {
            isClick = true;
            controller.GoToExit();
        }
            
    }
}
