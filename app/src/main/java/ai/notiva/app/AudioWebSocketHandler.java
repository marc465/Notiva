package ai.notiva.app;

import java.io.IOException;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

@Component
public class AudioWebSocketHandler extends TextWebSocketHandler {

    private final JwtTokenUtil tokenUtil;
    private AudioSessionManager audioSessions;


    @Autowired
    public AudioWebSocketHandler(JwtTokenUtil tokenUtil, AudioSessionManager audioSessions) {
        this.tokenUtil = tokenUtil;
        this.audioSessions = audioSessions;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        System.out.println(session.getId());
        try {
            String[] temp = session.getUri().toString().split("/");
            System.out.println(temp);
            String access_token = temp[5];

            if (!tokenUtil.validateToken(access_token)) {
                session.close(CloseStatus.NOT_ACCEPTABLE);
                System.out.println("Invalid token");
                return;
            }
            AudioSession newAudioSession = new AudioSession();
            newAudioSession.setPaused(false);

            audioSessions.addSession(tokenUtil.getUserIdFromToken(access_token) + " " + temp[6], newAudioSession);

            System.out.println("Client connected: " + session.getId());
            
        } catch (Exception e) {
            System.out.println("Error in afterConnectionEstablished");
            e.printStackTrace();
        }
    }


    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        System.out.println(session);
        System.out.println(session.getId());
        System.out.println(session.getUri());
        System.out.println(message);
        System.out.println(message.getPayload());

        String payload = message.getPayload();
        JSONObject json = new JSONObject(payload);

        String command = json.getString("command"); // play, pause, stop, seek

        String[] temp = session.getUri().toString().split("/");

        String access_token = temp[5];
        String audioSessionId = String.valueOf(tokenUtil.getUserIdFromToken(access_token)) + " " + temp[6];

        switch (command) {
            case "play":
                // Знімаємо паузу
                audioSessions.getSession(audioSessionId).setPaused(false);
                System.out.println(command);
                System.out.println(audioSessions.getSession(audioSessionId).isPaused());
                break;
            case "pause":
                // Ставимо на паузу
                audioSessions.getSession(audioSessionId).setPaused(true);
                System.out.println(command);
                System.out.println(audioSessions.getSession(audioSessionId).isPaused());
                break;
            case "stop":
                // Закриваємо сесію
                audioSessions.getSession(audioSessionId).setPaused(true);
                audioSessions.removeSession(audioSessionId);
                System.out.println(command);
                System.out.println(audioSessions.getSession(audioSessionId).isPaused());

                try {
                    session.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                break;
        }
    }
}
