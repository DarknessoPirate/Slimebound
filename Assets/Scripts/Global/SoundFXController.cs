using UnityEngine;

public class SoundFXController : MonoBehaviour
{
    public PlayerControllerRevamped playerController;
    public AudioClip jumpSound;
    public AudioClip airJumpSound;
    public AudioClip ceilingHitSound;
    public AudioClip cameraChangeSound;
    public AudioClip moveSound;
    public AudioSource audioSourceForMoveSound;
    private AudioSource audioSource;

    private void playJumpSound()
    {
        audioSource.PlayOneShot(jumpSound);
    }
    private void playAirJumpSound()
    {
        audioSource.PlayOneShot(airJumpSound);
    }
    private void playCameraChangeSound()
    {
        audioSource.PlayOneShot(cameraChangeSound);
    }
    private void playCeilingHitSound()
    {
        audioSource.PlayOneShot(ceilingHitSound);
    }
    private void playMoveSound(float speed)
    {
        if(audioSourceForMoveSound.isPlaying && speed <= 0.01f)
        {
            audioSourceForMoveSound.Pause();
        }
        else if(!audioSourceForMoveSound.isPlaying && speed >= 0.01f)
        {
            audioSourceForMoveSound.Play();
        }
        
    }
    // Update is called once per frame
    private void Start()
    {
        audioSource = GetComponent<AudioSource>();
        playerController.OnPerformedJump += playJumpSound;
        playerController.OnPerformedAirJump += playAirJumpSound;
        playerController.OnChangedAxis += playCameraChangeSound;
        playerController.OnHitCeiling += playCeilingHitSound;
        playerController.OnMove += playMoveSound;
    }
}
