using Unity.VisualScripting;
using UnityEngine;

public class PauseMenu : MonoBehaviour
{
    [SerializeField] GameObject pauseMenu;
    [SerializeField] SceneController sceneController;
    bool isActive = false;

    public void Update()
    {
        if(Input.GetKeyDown(KeyCode.Escape))
        {
            if (!isActive)
            {
                Pause();
            }
            else
            {
                Resume();
            }
        }
        
    }


    public void Pause()
    {
        pauseMenu.SetActive(true);
        isActive = true;
        Time.timeScale = 0f;
    }

    public void Resume()
    {
        pauseMenu.SetActive(false);
        isActive = false;
        Time.timeScale = 1.0f;
    }

    public void BackToMenu()
    {
        Time.timeScale = 1.0f;
        sceneController.GoToScene(0);
    }
}
