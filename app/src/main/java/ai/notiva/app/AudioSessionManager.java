package ai.notiva.app;

import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

@Service
public class AudioSessionManager {

    private final ConcurrentHashMap<String, AudioSession> audioSessions = new ConcurrentHashMap<>();

    public AudioSession getSession(String key) {
        return audioSessions.get(key);
    }

    public void addSession(String key, AudioSession session) {
        audioSessions.put(key, session);
    }

    public void removeSession(String key) {
        audioSessions.remove(key);
    }

    public boolean sessionExists(String key) {
        return audioSessions.containsKey(key);
    }

    public ConcurrentHashMap<String, AudioSession> getAllSessions() {
        return audioSessions;
    }
}