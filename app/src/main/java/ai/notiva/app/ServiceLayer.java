package ai.notiva.app;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Base64;

import org.springframework.stereotype.Service;

@Service
public class ServiceLayer {
    
    public String saveAudio(Long user_id, String notes_name, String encodedAudio) throws IOException{
        byte[] audioData = Base64.getDecoder().decode(encodedAudio);

        String direcrory = "../audiofiles/";
        String fileName =  "_" + notes_name.replaceAll("[^a-zA-Z0-9_\\-]", "_") + "_" + System.currentTimeMillis() + ".mp3";

        File dir = new File(direcrory);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        File audioFile = new File(direcrory + fileName);

        try (FileOutputStream f = new FileOutputStream(audioFile)) {
            f.write(audioData); 
        }

        return audioFile.getAbsolutePath();
    }
    
    public String generateSummary(String transcript) {
        return "";
    }

    public String generateIcon(String name) {
        return "";
    }

    public boolean validateUserCredentials(String username, String password, String email) {
        if (username == null || username.trim().isEmpty() || username.length() > 64) {
            return false;
        }

        if (password == null || password.trim().isEmpty() || password.length() < 8 || password.length() > 32) {
            return false;
        }

        if (email == null || email.trim().isEmpty() || email.length() > 255) {
            return false;
        }

        String passwordPattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,32}$";
        if (!password.matches(passwordPattern)) {
            return false;
        }

        String emailPattern = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        if (!email.matches(emailPattern)) {
            return false;
        }

        return true;
    }


}
