package ai.notiva.app;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.List;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.net.URI;

import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import ai.notiva.app.entities.Message;

@Service
public class ServiceLayer {
    HttpClient client = HttpClient.newHttpClient();

    @Value("${gemini.api.key}")
    private String apiKey;
    
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
    
    public String generateSummary(String transcript) throws IOException, InterruptedException {



        JSONObject textPart = new JSONObject();
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("Transform the given transcript in delta into a well-structured and visually enhanced summary using Quill Delta format. ")
              .append("Improve readability by applying appropriate formatting, such as headings, bold, italics, bullet points, and other relevant styles where logical. ")
              .append("Prioritize clarity, conciseness, and easy comprehension while maintaining the original meaning of the text. ")
              .append("Make only necessary edits for grammar, spelling, and flow without altering key information. ")
              .append("Ensure that the final output is structured effectively to highlight the most important insights. ")
              .append("The summary should follow this preferred structure when applicable:\n\n")
              
              .append("👉 **Key Actions:** Clearly defined steps, decisions, or required actions.\n")
              .append("🔹 **Key Features:** Essential points, highlights, or noteworthy elements.\n")
              .append("📌 **Main Ideas:** Core concepts, themes, or takeaways.\n")
              .append("💡 **Insights & Recommendations:** Additional helpful information, clarifications, or suggested next steps.\n")
              .append("❓ **Potential Questions & Clarifications:** Any missing details or areas where further explanation might be useful.\n")
              .append("📝 **Summary:** Concise recap of the main discussion points.\n\n")
              
              .append("The AI should use only the sections that are logical and relevant for this particular summary. However, the '📝 Summary' section is mandatory and must always be included. ")
              .append("Lists, emojis, and formatting should be used intelligently to enhance readability and user experience—modern, visually appealing, but never overwhelming. ")
              .append("If applicable, the AI can also add relevant elements to enrich the summary, such as clarifications on unknown facts or additional insights based on the content.")
              .append("Ensure the response is a properly formatted Quill Delta JSON object, ready for direct use in a Quill editor.\n")
              .append("Transcript in Quill Delta format: " + transcript);
        
        textPart.put("text", prompt.toString());

        
        JSONArray part = new JSONArray();
        part.put(textPart);
    
        JSONObject contents = new JSONObject();
        contents.put("parts", part);
    
        JSONArray contentsArray = new JSONArray();
        contentsArray.put(contents);
    
        JSONObject requestBody = new JSONObject();
        requestBody.put("contents", contentsArray);


        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(String.format("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=%s", apiKey)))
            .header("Content-Type", "application/json")
            .POST(java.net.http.HttpRequest.BodyPublishers.ofString(requestBody.toString(), StandardCharsets.UTF_8))
            .build();

        System.out.println(2);
        
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.statusCode() + " --- " + response.headers());
        System.out.println("Response: " + response.body());

        JSONObject jsonResponse = new JSONObject(response.body());
        JSONArray candidates = jsonResponse.getJSONArray("candidates");
        
        if (candidates.length() > 0) {
            JSONObject firstCandidate = candidates.getJSONObject(0);
            JSONArray parts = firstCandidate.getJSONObject("content").getJSONArray("parts");

            if (parts.length() > 0) {
                String deltaText = parts.getJSONObject(0).getString("text");  // Extract corrected text
                try {
                    new JSONObject(deltaText); // Якщо це валідний JSON, повертаємо як є
                    return deltaText;
                } catch (Exception e) {
                    // Якщо це не JSON, конвертуємо в Delta формат
                    JSONObject delta = new JSONObject();
                    JSONArray ops = new JSONArray();
                    
                    JSONObject insert = new JSONObject();
                    insert.put("insert", deltaText);
                    ops.put(insert);
                    
                    delta.put("ops", ops);
                    return delta.toString();
                }
            }
        }
        
        return "";
    }

    public String generateIcon(String name, String summary) throws IOException, InterruptedException {
        JSONObject textPart = new JSONObject();
        textPart.put("text", "Generate a single UTF-8 emoji that best represents the given note based on its title and summary. "
            + "The emoji should reflect the main idea, mood, or theme of the note.\n\n"
            + "💡 Rules:\n\n"
            + "• Respond with only one emoji (no text, no explanations, no extra symbols).\n"
            + "• Choose the most relevant emoji based on the provided information.\n"
            + "• Ensure the emoji aligns with the content meaningfully.\n\n"
            + "📌 Title: " + name + "\n"
            + "📄 Summary: " + summary + "\n\n"
            + "🎯 Your Response: [Only one emoji]"
        );
    
        JSONArray part = new JSONArray();
        part.put(textPart);
    
        JSONObject contents = new JSONObject();
        contents.put("parts", part);
    
        JSONArray contentsArray = new JSONArray();
        contentsArray.put(contents);
    
        JSONObject requestBody = new JSONObject();
        requestBody.put("contents", contentsArray);
    

        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(String.format("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=%s", apiKey)))
            .header("Content-Type", "application/json")
            .POST(java.net.http.HttpRequest.BodyPublishers.ofString(requestBody.toString(), StandardCharsets.UTF_8))
            .build();

        System.out.println(3);

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.statusCode() + " --- " + response.headers());
        System.out.println("Response: " + response.body());

        JSONObject jsonResponse = new JSONObject(response.body());
        JSONArray candidates = jsonResponse.getJSONArray("candidates");
        
        if (candidates.length() > 0) {
            JSONObject firstCandidate = candidates.getJSONObject(0);
            JSONArray parts = firstCandidate.getJSONObject("content").getJSONArray("parts");

            if (parts.length() > 0) {
                return parts.getJSONObject(0).getString("text");  // Extract corrected text
            }
        }
        
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

    public long[] validateRanges(String range, long fileLength) {
        long start;
        long end;
        // Calculate max allowed range (3 minutes of audio)
        // Assuming 128 kbps audio

        String[] ranges = range.replace("bytes=", "").split("-");
        try {
            start = Long.parseLong(ranges[0]);
            if (start >= fileLength || start < 0) {
                start = 0;
            }
            
            end = ranges.length > 1 && !ranges[1].isEmpty() 
                ? Long.parseLong(ranges[1])
                : fileLength;

            if (end < 0) {
                end *= -1;
            }
            if (end >= fileLength) {
                end = fileLength;
            }

            System.out.println("returning values are:" + start + " " + end);
            return new long[] {start, end};

        } catch (NumberFormatException e) {
            start = 0;
            end = fileLength;

            return new long[] {start, end};
        }
    }

    public String normalizeTranscript(String raw, String comment) throws IOException, InterruptedException {
        // send request for ChatGPT and ask for text normalization:
        // gramatic, punctuation, chage words or symbols using context (if needed if wrong transcripted) etc

        JSONObject textPart = new JSONObject();
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("Convert the given transcript into a properly formatted Quill Delta document. ")
              .append("Enhance readability by adding appropriate headings, bold, italic, strikethrough, and other formatting where logical. ")
              .append("Ensure the text remains user-friendly, well-structured, and visually appealing while preserving its original meaning. ")
              .append("Make only necessary changes to improve grammar, spelling, and natural flow without altering the core message. ");
        
        if (comment != null && !comment.isEmpty()) {
            prompt.append("Take into account the user's comment for adjustments: \"")
                  .append(comment)
                  .append("\". ");
        }
        
        prompt.append("Return a valid Quill Delta JSON format as the response. ");
        
        textPart.put("text", prompt.toString() + " Transcript: " + raw);
    
        JSONArray part = new JSONArray();
        part.put(textPart);
    
        JSONObject contents = new JSONObject();
        contents.put("parts", part);
    
        JSONArray contentsArray = new JSONArray();
        contentsArray.put(contents);
    
        JSONObject requestBody = new JSONObject();
        requestBody.put("contents", contentsArray);

        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(String.format("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=%s", apiKey)))
            .header("Content-Type", "application/json")
            .POST(java.net.http.HttpRequest.BodyPublishers.ofString(requestBody.toString(), StandardCharsets.UTF_8))
            .build();

        System.out.println(requestBody.toString());
        System.out.println(1);

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.statusCode() + " --- " + response.headers());
        System.out.println("Response: " + response.body());

        JSONObject jsonResponse = new JSONObject(response.body());
        JSONArray candidates = jsonResponse.getJSONArray("candidates");
        
        if (candidates.length() > 0) {
            JSONObject firstCandidate = candidates.getJSONObject(0);
            JSONArray parts = firstCandidate.getJSONObject("content").getJSONArray("parts");

            if (parts.length() > 0) {
                String deltaText = parts.getJSONObject(0).getString("text");  // Extract corrected text
                try {
                    new JSONObject(deltaText); // Якщо це валідний JSON, повертаємо як є
                    return deltaText;
                } catch (Exception e) {
                    // Якщо це не JSON, конвертуємо в Delta формат
                    JSONObject delta = new JSONObject();
                    JSONArray ops = new JSONArray();
                    
                    JSONObject insert = new JSONObject();
                    insert.put("insert", deltaText);
                    ops.put(insert);
                    
                    delta.put("ops", ops);
                    return delta.toString();
                }
            }
        }
        
        return "";
    } 

    public String extractPlainTextFromDelta(String deltaJson) {
        try {
            JSONObject delta = new JSONObject(deltaJson);
            JSONArray ops = delta.getJSONArray("ops");
            StringBuilder plainText = new StringBuilder();
            
            for (int i = 0; i < ops.length(); i++) {
                JSONObject op = ops.getJSONObject(i);
                if (op.has("insert")) {
                    Object insert = op.get("insert");
                    if (insert instanceof String) {
                        plainText.append(insert);
                    }
                }
            }
            
            return plainText.toString().trim();
        } catch (Exception e) {
            System.err.println("Error parsing Delta JSON: " + e.getMessage());
            return deltaJson; // повертаємо оригінальний текст якщо парсинг не вдався
        }
    }

    public boolean validateIcon(String icon) {
        // Somehow create icon validation (its must be an smile, icon etc - not text)
        return true;
    }

    public long getBitrate(File file) {
        AudioFile audio;
        try {
            audio = AudioFileIO.read(file);
            return audio.getAudioHeader().getBitRateAsNumber();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public String getChatbotResponse(List<Message> messages, String transcript, String summary) throws IOException, InterruptedException {

        // Create request to AI with system instruction
        JSONObject requestBody = new JSONObject();
        
            JSONObject sysText = new JSONObject();
            sysText.put("text", "You are NotivaAI, a chatbot within the Notiva app, designed to help users with their voice notes. You specialize in working with transcripts, and summaries (note contains audio, transcripts, and summaries). Your role is to assist users by responding to their inquiries based on their note transcripts and summaries.\n" + //
                                "\n" + //
                                "System Rules:\n" + //
                                "1 Identity & Role: You are NotivaAI, the official chatbot of the Notiva app. You help users understand, analyze, and interact with their voice notes.\n" + //
                                "2 Access Limitations: You do not have access to the original audio files, only the transcript and summary.\n" + //
                                "3 User Interaction: The user sends a message, and you respond in a helpful, conversational, and engaging manner.\n" + //
                                "4 Functionality:\n" + //
                                "\n" + //
                                "Use the provided transcript to understand the note's full details.\n" + //
                                "Refer to the summary for a quick context.\n" + //
                                "Help the user clarify, expand on, or analyze the note.\n" + //
                                "Offer insights, suggestions, or actionable next steps.\n" + //
                                "5 Stay on Topic: Focus only on the provided transcript and summary. If a user asks something unrelated, politely guide them back to their notes.\n" + //
                                "Note Transcript:\n" + //
                                transcript + "\n" + //
                                "\n" + //
                                "Summary:\n" + //
                                summary + "\n" + //
                                "\n" + //
                                "Now, respond as NotivaAI, helping the user with their note.\n");

            JSONObject sysParts = new JSONObject();
            sysParts.put("parts", sysText);

        requestBody.put("system_instruction", sysParts);


        // Add history messages to reuest
        JSONArray contentsArray = new JSONArray();

        for (Message message : messages) {

            JSONObject result = new JSONObject();

                JSONObject textPart = new JSONObject();
                textPart.put("text", message.getMessage());

                JSONArray part = new JSONArray();
                part.put(textPart);

            if (message.getSender()) {
                result.put("role", "user");
            } else {
                result.put("role", "model");
            }

            result.put("parts", part);
            contentsArray.put(result);
        }

        requestBody.put("contents", contentsArray);


        // Send request to AI
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(String.format("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=%s", apiKey)))
            .header("Content-Type", "application/json")
            .POST(java.net.http.HttpRequest.BodyPublishers.ofString(requestBody.toString(), StandardCharsets.UTF_8))
            .build();

        System.out.println(56);

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.statusCode() + " --- " + response.headers());
        System.out.println("Response: " + response.body());

        JSONObject jsonResponse = new JSONObject(response.body());
        JSONArray candidates = jsonResponse.getJSONArray("candidates");
        

        // Return response from AI
        if (candidates.length() > 0) {
            JSONObject firstCandidate = candidates.getJSONObject(0);
            JSONArray parts = firstCandidate.getJSONObject("content").getJSONArray("parts");

            if (parts.length() > 0) {
                return parts.getJSONObject(0).getString("text");  // Extract corrected text
            }
        }
        
        return "";
    }
}
