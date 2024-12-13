using UnityEngine;

public class ColliderTransformerHelper : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
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
        if(!_stayTrigger)
        {
            if (_timer > 0 && _timer < 3)
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

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            _stayTrigger = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            _stayTrigger = false;
            GetComponent<Collider>().isTrigger = false;
        }
    }
}
