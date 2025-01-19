using UnityEngine;

public class EndGame : MonoBehaviour
{
    [SerializeField] SceneController controller;
    bool isClick = false;

    public void BackToMenu()
    {
        if (!isClick)
            controller.GoToScene(0);
    }
}
