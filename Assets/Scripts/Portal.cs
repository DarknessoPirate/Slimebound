using UnityEngine;
using UnityEngine.SceneManagement;

public class Portal : MonoBehaviour
{
    [SerializeField] SceneController controller;
    [SerializeField] GameObject interaction;
    [SerializeField] int scene = 0;

    bool isActive = false;

    private void Update()
    {
        if(isActive)
        {
            if (Input.GetKeyDown(KeyCode.Return))
            {
                controller.GoToScene(scene);
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            isActive = true;
            interaction.SetActive(true);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            isActive = false;
            interaction.SetActive(false);
        }
    }
}
