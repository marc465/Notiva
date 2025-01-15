package ai.notiva.app;
import org.springframework.stereotype.Component;

@Component
class AudioSession {
    private boolean paused;

    public AudioSession() {
        this.paused = true;
    }

    public boolean isPaused() {
        return paused;
    }

    public void setPaused(boolean paused) {
        this.paused = paused;
    }
}
