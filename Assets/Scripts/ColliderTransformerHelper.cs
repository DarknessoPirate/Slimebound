using UnityEngine;

public class ColliderTransformerHelper : MonoBehaviour
{
    /*
    This code is responsible for handling situation where player would be stuck in collider
    after change of axis.
    */

    private int _timer = 1;
    private bool _stayTrigger = false;

    public void InitCollider()
    {
        GetComponent<Collider>().isTrigger = true;
        _timer = 1;
        _stayTrigger = false;
    }

    void Start()
    {
        GetComponent<Collider>().isTrigger = true;
    }

    // Update is called once per frame
    void Update()
    {
        // 2-Frame-check if player might be stuck,
        // returns to solid block if not.

        if(!_stayTrigger && _timer > 0)
        {
            if (_timer < 3)
            {
                _timer++;
            }
            else if (_timer == 3)
            {
                GetComponent<Collider>().isTrigger = false;
                _timer = 0;
            }
        }
    }

    // Player would be stuck in collider
    private void OnTriggerStay(Collider other)
    {
        if(other.tag == "Player")
        {
            _stayTrigger = true;
        }
    }

    // Player no longer would be stuck in collider
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            _stayTrigger = false;
            GetComponent<Collider>().isTrigger = false;
        }
    }
}
