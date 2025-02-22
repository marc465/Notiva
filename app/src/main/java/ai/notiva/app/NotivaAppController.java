package ai.notiva.app;

import ai.notiva.app.DTO.FolderDTO;
import ai.notiva.app.DTO.NoteForReviewDTO;
import ai.notiva.app.DTO.QuickFolder;
import ai.notiva.app.DTO.TagDTO;
import ai.notiva.app.DTO.QuickNote;
import ai.notiva.app.Requsts.CreateAccountRequest;
import ai.notiva.app.Requsts.LoginRequest;
import ai.notiva.app.entities.Folder;
import ai.notiva.app.entities.Message;
import ai.notiva.app.entities.Note;
import ai.notiva.app.entities.Tag;
import ai.notiva.app.entities.User;
import ai.notiva.app.repositories.ChatBotMessagesRepository;
import ai.notiva.app.repositories.FolderRepository;
import ai.notiva.app.repositories.NoteRepository;
import ai.notiva.app.repositories.TagRepository;
import ai.notiva.app.repositories.UserRepository;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.net.URI;
// import java.net.http.HttpRequest;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
// import java.util.Enumeration;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

// import org.apache.catalina.connector.Request;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;


@RestController
public class NotivaAppController {

    private final JwtTokenUtil tokenUtil;
    private final TagRepository tagRepository;
    private final UserRepository userRepository;
    private final NoteRepository noteRepository;
    private final FolderRepository folderRepository;
    private final ChatBotMessagesRepository chatBotMessagesRepository;
    private final ServiceLayer service;
    private AudioSessionManager audioSessions;


    @Autowired
    public NotivaAppController(NoteRepository noteRepository, JwtTokenUtil tokenUtil, FolderRepository folderRepository, UserRepository userRepository, TagRepository tagRepository, ServiceLayer service, AudioSessionManager audioSessions, ChatBotMessagesRepository chatBotMessagesRepository) {
        this.tokenUtil = tokenUtil;
        this.tagRepository = tagRepository;
        this.noteRepository = noteRepository;
        this.userRepository = userRepository;
        this.folderRepository = folderRepository;
        this.chatBotMessagesRepository = chatBotMessagesRepository;
        this.service = service;
        this.audioSessions = audioSessions;
    }
    
    @GetMapping(path = "/")
    public String homePage() {
        return "Hello Notiva!";
    }

    @GetMapping(path = "/login")
    public String loginPage() {
        return "login";
    }

    @PostMapping(path = "/signup")
    public ResponseEntity<?> signup(
        @RequestBody CreateAccountRequest createAccountRequest, 
        HttpServletResponse response) {
        try {
            String username = createAccountRequest.getUsername();
            String password = createAccountRequest.getPassword();
            String email = createAccountRequest.getEmail();

            if (!service.validateUserCredentials(username, password, email)) {
                return ResponseEntity.status(400).body("Incorrect credential");
            }

            if (userRepository.findByEmail(email) == null
                && userRepository.findByUsername(username) == null) {

                User newUser = new User();
                newUser.setUsername(username);
                newUser.setEmail(email);
                newUser.setPassword(password);
                newUser.setVip(false);
                newUser.setDateOfCreation(Timestamp.valueOf(LocalDateTime.now()));

                userRepository.save(newUser);

                String user_id = String.valueOf(newUser.getId());

                String accessToken = tokenUtil.generateAccessToken(user_id);
                String refreshToken = tokenUtil.generateRefreshToken(user_id);

                Cookie refreshCookie = new Cookie("refresh_token", refreshToken);
                refreshCookie.setHttpOnly(true);
                refreshCookie.setSecure(true);
                refreshCookie.setPath("/");
                refreshCookie.setMaxAge(7 * 24 * 60 * 60);

                response.addCookie(refreshCookie);
                response.addHeader("access_token", accessToken);

                return ResponseEntity.status(200).body(null);
            }
            
            return ResponseEntity.status(409).body("User with this email or username exists");
        } catch (Exception e) {
            return ResponseEntity
                .status(500)
                .body("Something Went Wrong On Server :(");
        }
    }

    @PostMapping(path = "/login")
    public ResponseEntity<?> postLoginPage(
        @RequestBody LoginRequest loginRequest, 
        HttpServletResponse response) {
        try {
            User user = userRepository.findByUsernameAndPassword(loginRequest.getUsername(), loginRequest.getPassword());

            if (user != null) {
                String user_id = String.valueOf(user.getId());

                String accessToken = tokenUtil.generateAccessToken(user_id);
                String refreshToken = tokenUtil.generateRefreshToken(user_id);

                Cookie refreshCookie = new Cookie("refresh_token", refreshToken);
                refreshCookie.setHttpOnly(true);
                refreshCookie.setSecure(true);
                refreshCookie.setPath("/");
                refreshCookie.setMaxAge(7 * 24 * 60 * 60);

                response.addCookie(refreshCookie);
                response.addHeader("access_token", accessToken);

                return ResponseEntity.status(200).body(null);
            }
            return ResponseEntity.status(400).body("Invalid username or password");
        } catch (Exception e) {
            return ResponseEntity
                .status(500)
                .body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "/notes/get")
    public ResponseEntity<?>  getNotesList(
        @RequestHeader("access_token") String token, 
        HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }
            return ResponseEntity
                .status(200)
                .body(noteRepository.findQuickNoteByUser_id(tokenUtil.getUserIdFromToken(token)));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "/folders/get")
    public ResponseEntity<?> getFoldersList(
        @RequestHeader("access_token") String token, 
        HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }
            return ResponseEntity
                .status(200)
                .body(folderRepository.findQuickFolderByUser_id(tokenUtil.getUserIdFromToken(token)));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "/favourites/get")
    public ResponseEntity<?> getFavouritesList(
        @RequestHeader("access_token") String token, 
        HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }
            return ResponseEntity
                .status(200)
                .body(noteRepository.findQuickFavouriteNotesByUserIdAndFavourite(tokenUtil.getUserIdFromToken(token)));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "/tags/get")
    public ResponseEntity<?> getTagsList(
        @RequestHeader("access_token") String token) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }
            return ResponseEntity.status(200).body(tagRepository.findAllByUserId(tokenUtil.getUserIdFromToken(token)));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "note/view")
    public ResponseEntity<?> getNote(
        @RequestHeader("access_token") String token, 
        @RequestHeader("note_id") Long note_id, 
        HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid.");
            }

            Note note = noteRepository.findNoteByIdAndUserId(tokenUtil.getUserIdFromToken(token), note_id);
            File file = new File(note.getAudio());
            long bps = service.getBitrate(file);
            NoteForReviewDTO noteForReview = new NoteForReviewDTO(note, file.length(), bps);

            System.out.println(note.getTranscript_jsonb());
            System.out.println(noteForReview);

            return ResponseEntity.ok().body(noteForReview);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "note/audio")
    public ResponseEntity<?> getNoteAudio(
        @RequestHeader("access_token") String token,
        @RequestHeader("note_id") Long noteId,
        @RequestHeader(value = "Range", required = false) String range,
        @RequestHeader(value = "icy-metadata", required = false) String icyMetadata,
        HttpServletRequest request,
        HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid.");
            }
    
            Long userId = tokenUtil.getUserIdFromToken(token);
            Note note = noteRepository.findNoteByIdAndUserId(userId, noteId);

            if (note == null || !(note.getUserId().equals(userId))) {
                return ResponseEntity.status(400).body("Wrong note id.");
            }

    
            String key = userId + " " + noteId;
            if (audioSessions.getSession(key) == null) {
                return ResponseEntity.status(400).body("Session isn't initialized.");
            }

            File audioFile = new File(note.getAudio());
            long fileLength = audioFile.length();

            if (range == null && "1".equals(icyMetadata)) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.setHeader("Source-Length", String.valueOf(fileLength));
                return null;
            }

            long start;
            long end;
            long[] startEnd = service.validateRanges(range, fileLength);
            start = startEnd[0];
            end = startEnd[1];
            long contentLength = (end - start) + 1;
    
            response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT); // 206 Partial Content

            response.setHeader(HttpHeaders.CONTENT_TYPE, "audio/mp3");
            response.setHeader(HttpHeaders.CONTENT_RANGE, "bytes " + start + "-" + (end) + "/" + fileLength);
            response.setHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(contentLength));
            response.setHeader(HttpHeaders.ACCEPT_RANGES, "bytes");
            response.setHeader(HttpHeaders.SERVER, "NotivaS");
            response.setHeader(HttpHeaders.CACHE_CONTROL, "no-cache");        

            try (RandomAccessFile raf = new RandomAccessFile(audioFile, "r");
                OutputStream outputStream = response.getOutputStream()) {

                raf.seek(start);
                byte[] buffer = new byte[65536]; // 65 KB буфер
                int bytesReaded;
                long bytesToWrite = contentLength;

                while ((bytesReaded = raf.read(buffer, 0, (int) Math.min(buffer.length, bytesToWrite))) > 0) {
                    if (audioSessions.getSession(key).isPaused()) {
                        break;
                    }
                    outputStream.write(buffer, 0, bytesReaded);
                    outputStream.flush();
                    bytesToWrite -= bytesReaded;
                }
            }
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "folder/view")
    public ResponseEntity<?> getFolder(
        @RequestHeader("access_token") String token, 
        @RequestHeader("folder_id") Long folder_id, 
        HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid.");
            }

            long user_id = tokenUtil.getUserIdFromToken(token);
            Folder folder = folderRepository.findFolderByIdAndUserId(user_id, folder_id);
            List<QuickNote> notes = folderRepository.findNotesInFolderByNoteIdAndUserId(user_id, folder_id);

            Map<String, Object> result = new HashMap<String, Object>();
            result.put("folder", folder);
            result.put("notes_inside", notes);

            return ResponseEntity.ok().body(result);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "folder/view/avaiable")
    public ResponseEntity<?> getAvaiableNotesToFolder(
        @RequestHeader("access_token") String token, 
        @RequestHeader("folder_id") Long folder_id, 
        @RequestHeader(value = "except", required = false) String exceptNotesString, 
        HttpServletResponse response) {
            System.out.println("in folder available");
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid.");
            }

            long user_id = tokenUtil.getUserIdFromToken(token);
            Folder folder = folderRepository.findFolderByIdAndUserId(user_id, folder_id);

            if (folder == null) {
                return ResponseEntity.status(400).body("Folder id is invalid.");
            }

            ObjectMapper mapper = new ObjectMapper();
            List<Long> exceptNotes = mapper.readValue(exceptNotesString, new TypeReference<List<Long>>(){});

            List<QuickNote> notes = noteRepository.findNotesWithExceptions(user_id, exceptNotes);

            return ResponseEntity.ok().body(notes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "tag/view")
    public ResponseEntity<?> getTag(
        @RequestHeader("access_token") String token, 
        @RequestHeader("tag_id") Long tag_id, 
        HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid.");
            }

            Long userId = tokenUtil.getUserIdFromToken(token);

            List<QuickNote> notes = tagRepository.findNotesByTagIdAndUserId(userId, tag_id);
            Tag tag = tagRepository.findByTagIdAndUserId(userId, tag_id);

            HashMap<String, Object> result = new HashMap<String, Object>();
            result.put("tag", tag);
            result.put("notes_inside", notes);

            return ResponseEntity.ok().body(result);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "tag/view/avaiable")
    public ResponseEntity<?> getAvaiableNotesToTag(
        @RequestHeader("access_token") String token, 
        @RequestHeader("except") String exceptNotesString, 
        HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid.");
            }

            long user_id = tokenUtil.getUserIdFromToken(token);

            ObjectMapper mapper = new ObjectMapper();
            List<Long> exceptNotes = mapper.readValue(exceptNotesString, new TypeReference<List<Long>>(){});

            List<QuickNote> notes = noteRepository.findNotesWithExceptions(user_id, exceptNotes);

            return ResponseEntity.ok().body(notes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @PostMapping(path = "note/is/favourite")
    public ResponseEntity<?> setFavouriteNoteState(
        @RequestHeader("access_token") String token,
        @RequestHeader("note_id") long id,
        @RequestHeader("value") boolean value
    ) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid.");
            }

            Note note = noteRepository.findNoteByIdAndUserId(tokenUtil.getUserIdFromToken(token), id);
            
            if (note == null) {
                return ResponseEntity.status(400).body("Note id is invalid");
            }

            if (note.is_favourite() == value) {
                return ResponseEntity.status(200).body(null);
            }

            note.set_favourite(value);
            noteRepository.save(note);

            return ResponseEntity.status(200).body(null);

        } catch (Exception e) {
            System.out.println(e);
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "search/in/notes")
    public ResponseEntity<?> searchInNotes(
        @RequestHeader("query") String q, 
        @RequestHeader("access_token") String token,
        @RequestHeader(name = "favourite", required = false) boolean is_favourite
    ) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }
            long userToken = tokenUtil.getUserIdFromToken(token);
            List<QuickNote> notes;

            if (is_favourite) {
                notes = noteRepository.favouritesFulltextSearch(userToken, q);
            } else {
                notes = noteRepository.fulltextSearch(userToken, q);
            }
            
            return ResponseEntity.status(200).body(notes);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "search/in/folder/notes")
    public ResponseEntity<?> searchInNotesInside(
        @RequestHeader("query") String q, 
        @RequestHeader("access_token") String token,
        @RequestHeader(name = "folder_id", required = false) Long folder_id
    ) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            long userId = tokenUtil.getUserIdFromToken(token);
            List<QuickNote> notes;
            notes = noteRepository.fulltextSearchInsideFolder(userId, folder_id, q);
            
            return ResponseEntity.status(200).body(notes);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "search/in/tag/notes")
    public ResponseEntity<?> searchNotesInsideTag(
        @RequestHeader("query") String q, 
        @RequestHeader("access_token") String token,
        @RequestHeader("tag_id") Long tag_id
    ) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }
            long userId = tokenUtil.getUserIdFromToken(token);
            List<QuickNote> notes;
            notes = noteRepository.fulltextSearchInsideTag(userId, tag_id, q);
            
            return ResponseEntity.status(200).body(notes);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "search/in/folders")
    public ResponseEntity<?> searchInFolders(
        @RequestHeader("query") String q, 
        @RequestHeader("access_token") String token) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }
            long userToken = tokenUtil.getUserIdFromToken(token);
            List<QuickFolder> folders = folderRepository.fulltextSearch(userToken, q);
            
            return ResponseEntity.status(200).body(folders);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "search/in/tags")
    public ResponseEntity<?> searchInTags(
        @RequestParam("q") String q, 
        @RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(tagRepository.fulltextSearch(tokenUtil.getUserIdFromToken(token), q));
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "notes/searsh?q=" + q)
                .location(URI.create("/refresh/tokens"))
                .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @GetMapping(path = "ai/chat")
    public ResponseEntity<?> getMessages(
        @RequestHeader("access_token") String token,
        @RequestHeader("note_id") long id
    ) {
        try {
            if (tokenUtil.validateToken(token)) {
                Note note = noteRepository.findNoteByIdAndUserId(tokenUtil.getUserIdFromToken(token), id);
                if (note != null) {
                    List<Message> messages = chatBotMessagesRepository.findByNoteId(id);
                    System.out.println(messages);
                    return ResponseEntity
                        .ok()
                        .body(messages);
                } else {
                    return ResponseEntity.status(400).body("Note not found");
                }
            } else {
                return ResponseEntity
                    .status(307)
                    .header("redirect_uri", "ai/chat")
                    .location(URI.create("/refresh/tokens"))
                    .build();
            }
        } catch (Exception e) {
            System.out.println(e);
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @PostMapping(path = "ai/chat")
    public ResponseEntity<?> chatWithAi(
        @RequestHeader("access_token") String token,
        @RequestHeader("note_id") long id,
        @RequestBody Map<String, String> body
    ) {
        try {
            if (tokenUtil.validateToken(token)) {
                Note note = noteRepository.findNoteByIdAndUserId(tokenUtil.getUserIdFromToken(token), id);
                if (note != null) {
                    // 0. Get user message text
                    String message = body.get("message");
                    // 1. Save user message
                    Message userMessage = new Message();
                    userMessage.setMessage(message);
                    userMessage.setSender(true);
                    userMessage.setNoteId(id);
                    chatBotMessagesRepository.save(userMessage);
                    // 2. Get response from AI
                    List<Message> messages = chatBotMessagesRepository.findByNoteId(id);
                    String response = service.getChatbotResponse(messages, note.getTranscript(), note.getSummary());
                    // 3. Save AI response
                    Message aiMessage = new Message();
                    aiMessage.setMessage(response);
                    aiMessage.setSender(false);
                    aiMessage.setNoteId(id);
                    chatBotMessagesRepository.save(aiMessage);
                    // 4. Return AI response
                    return ResponseEntity
                        .status(200)
                        .body(aiMessage);
                } else {
                    return ResponseEntity.status(400).body("Note id is not valid");
                }
            } else {
                return ResponseEntity
                    .status(307)
                    .header("redirect_uri", "ai/chat")
                    .location(URI.create("/refresh/tokens"))
                    .build();
            }
        } catch (Exception e) {
            System.out.println(e);
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @PostMapping(path = "note/new/test")
    public ResponseEntity<?> testNote(
        // @RequestHeader("name") String name,
        // @RequestHeader(value = "icon", required = false) String userIcon,
        @RequestBody Map<String, String> body,
        @RequestHeader("access_token") String token) {
            System.out.println("in test");

            if (!tokenUtil.validateToken(token)) {
                System.out.println("token not valid");
                return null;
            }
            System.out.println("token valid");

            String raw = body.get("test_data");
            String com = body.get("comment");
            try {
                String nt = service.normalizeTranscript(raw, com);
                String gs = service.generateSummary(nt);

                System.out.println(nt);
                System.out.println("---------");
                System.out.println(gs);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

    @PostMapping(path = "note/new")
    public ResponseEntity<?> createNote(
        @RequestHeader(value = "icon", required = false) String userIcon,
        @RequestBody Map<String, String> body,
        @RequestHeader("access_token") String token) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            String name = body.get("name");
            String rawText = body.get("speech");
            String userComment = body.get("user_comment");

            Long user_id = tokenUtil.getUserIdFromToken(token);
            String correctTranscript = service.normalizeTranscript(rawText, userComment);
            System.out.println(correctTranscript);
            String summary = service.generateSummary(correctTranscript);
            String icon = (userIcon == null || !service.validateIcon(userIcon))? service.generateIcon(name, summary) : userIcon;

            Note newNote = new Note();
            newNote.setNotes_name(name);
            newNote.setSummary(service.extractPlainTextFromDelta(summary));
            newNote.setTranscript(service.extractPlainTextFromDelta(correctTranscript));
            newNote.setSummary_jsonb(summary);
            newNote.setTranscript_jsonb(correctTranscript);
            newNote.setTime_of_creation(Timestamp.valueOf(LocalDateTime.now()));
            newNote.setTime_of_last_changes(Timestamp.valueOf(LocalDateTime.now()));
            newNote.setUserId(user_id);
            newNote.setIcon(icon);
            newNote.set_favourite(false);
            newNote.set_everyone_can_access(false);
            newNote.setAudio(" ");

            noteRepository.save(newNote);

            return ResponseEntity.status(200).body(Collections.singletonMap("id", String.valueOf(newNote.getId())));
            
        } catch (Exception e) {
            System.out.println(e);
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @PostMapping(path = "note/new/audio")
    public ResponseEntity<?> createNoteAudio(
        @RequestHeader("id") Long id,
        @RequestHeader("part") Long part,
        @RequestParam("file") MultipartFile file,
        @RequestParam("offset") long offset,
        @RequestParam("filename") String filename,
        @RequestHeader("access_token") String token) {
        try {

            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            // String uploadDir = System.getProperty("user.dir") + File.separator + "uploads";

            // System.out.println(uploadDir);
            String wd = "src/main/resources/static";

            File directory = new File(wd);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            // Create full file path
            File audioFile = new File(wd + File.separator + filename);
            
            // Ensure parent directories exist
            audioFile.getParentFile().mkdirs();
            
            // Create file if not exists
            if (!audioFile.exists()) {
                try {
                    audioFile.createNewFile();
                } catch (Exception e) {
                    e.printStackTrace();
                    return ResponseEntity.status(500).body("Failed to create file");
                }
            }

            // Update note with file path if it's the first part
            if (part == 1) {
                noteRepository.updateAudio(id, audioFile.getAbsolutePath());
            }

            // Write chunk to file
            try (RandomAccessFile raf = new RandomAccessFile(audioFile, "rw")) {
                raf.seek(offset);
                raf.write(file.getBytes());
            } catch (Exception e) {
                e.printStackTrace();
                return ResponseEntity.status(500).body("Failed to write file chunk");
            }

            return ResponseEntity.ok("Chunk uploaded successfully");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong: " + e.getMessage());
        }
    }

    @PostMapping(path = "note/update")
    public ResponseEntity<?> updateNote(
        @RequestHeader("note_id") Long id,
        @RequestHeader("access_token") String token,
        @RequestBody Map<String, String> body,
        HttpServletRequest request) {
            System.out.println(request);
            System.out.println("--------------");
            System.out.println(token);
            System.out.println(id);
            System.out.println(body);
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            Note note = noteRepository.findNoteByIdAndUserId(tokenUtil.getUserIdFromToken(token), id);

            if (note == null) {
                return ResponseEntity.status(400).body("Note id is invalid");
            }

            if (body.containsKey("note_name")) {
                note.setNotes_name(body.get("note_name"));
            }
            if (body.containsKey("icon")) {
                note.setIcon(body.get("icon"));
            }
            if (body.containsKey("summary")) {
                String delta = body.get("summary");
                String rawText = service.extractPlainTextFromDelta(delta);
                note.setSummary(rawText);
                note.setSummary_jsonb(delta);
            }
            if (body.containsKey("transcript")) {
                String delta = body.get("transcript");
                String rawText = service.extractPlainTextFromDelta(delta);
                note.setTranscript(rawText);
                note.setTranscript_jsonb(delta);
            }

            note.setTime_of_last_changes(Timestamp.from(Instant.now()));

            noteRepository.save(note);

            return ResponseEntity.status(200).body(Collections.singletonMap("time_of_edit", note.getTime_of_last_changes()));
            
        } catch (Exception e) {
            System.out.println(e);
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @PostMapping(path = "folders/new")
    public ResponseEntity<?> createFolder(
        @RequestHeader("access_token") String token,
        @RequestBody FolderDTO folderData) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            if (folderData.getIdOfNotesInFolder() == null) {
                return ResponseEntity.status(400).body("List of notes id inside is invalid");
            }

            Long userId = userRepository.findById(tokenUtil.getUserIdFromToken(token)).get().getId();
            Folder newFolder = new Folder();

            if (folderData.getFolderName() == null || folderData.getFolderName().isEmpty()) {
                folderData.setFolderName("New Folder");
            }
            if (folderData.getIcon() == null || folderData.getIcon().isEmpty()) {
                folderData.setIcon("📁");
            }
            if (folderData.getFolderDescription() == null || folderData.getFolderDescription().isEmpty()) {
                folderData.setFolderDescription("Folder description");
            }

            newFolder.setFolder_name(folderData.getFolderName());
            newFolder.setDescription(folderData.getFolderDescription());
            newFolder.setIcon(folderData.getIcon());
            newFolder.setUser(userId);

            folderRepository.save(newFolder);
            long folder_id = newFolder.getId();

            for (long note_id : folderData.getIdOfNotesInFolder()) {
                Optional<Note> temp = noteRepository.findById(Long.valueOf(note_id));
                if (temp.isPresent()) {
                    if (temp.get().getUserId() == userId) {
                        folderRepository.saveNotesIdToNotes_Folders(folder_id, note_id);
                    }
                }
            }

            return ResponseEntity.status(200).body(Collections.singletonMap("folder_id", folder_id));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @PostMapping(path = "folders/update")
    public ResponseEntity<?> updateFolder(
        @RequestHeader("access_token") String token,
        @RequestHeader("folder_id") Long folder_id,
        @RequestBody Map<String, Object> body) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            Long userId = userRepository.findById(tokenUtil.getUserIdFromToken(token)).get().getId();
            Folder folder = folderRepository.findFolderByIdAndUserId(userId, folder_id);
            boolean hasChanges = false;

            if (folder == null) {
                return ResponseEntity.status(400).body("Invalid folder id");
            }

            if (body.containsKey("folderName")) {
                folder.setFolder_name((String) body.get("folderName"));
                hasChanges = true;
            }
            if (body.containsKey("folderDescription")) {
                folder.setDescription((String) body.get("folderDescription"));
                hasChanges = true;
            }
            if (body.containsKey("icon")) {
                folder.setIcon((String) body.get("icon"));
                hasChanges = true;
            }

            List<Long> notesInFolder;

            if (body.containsKey("idOfNotesInFolder")) {
                try {
                    notesInFolder = ((List<?>) body.get("idOfNotesInFolder"))
                        .stream()
                        .map(id -> Long.parseLong(id.toString()))
                        .collect(Collectors.toList());
                
                } catch(Exception e) {
                    System.out.println(e);
                    e.printStackTrace();
                    return ResponseEntity.status(400).body("Invalid notes id"); 
                }

                System.out.println(notesInFolder);

                Set<Long> currentNotesInFolder = noteRepository.findNotesInsideFolder(userId, folder_id)
                                                    .stream()
                                                    .map(note -> note.getId())
                                                    .collect(Collectors.toSet());

                System.out.println(currentNotesInFolder);

                Set<Long> notesToRemove = new HashSet<>(currentNotesInFolder);
                notesToRemove.removeAll(notesInFolder);

                System.out.println(notesToRemove);

                if (!notesToRemove.isEmpty()) {
                    System.out.println("to remove is not empty");
                    for (Long noteToRemove : notesToRemove) {
                        System.out.println(noteToRemove);
                        folderRepository.removeNoteFromFolder(folder_id, noteToRemove);
                    }
                }

                Set<Long> notesToAdd = new HashSet<>(notesInFolder);
                System.out.println(notesToAdd);
                notesToAdd.removeAll(currentNotesInFolder);
                System.out.println(notesToAdd);


                for (Long noteId : notesToAdd) {
                    System.out.println("need to put folders inside");
                    Note note = noteRepository.findNoteByIdAndUserId(userId, noteId);
                    if (note != null) {
                        folderRepository.saveNotesIdToNotes_Folders(folder_id, noteId);
                    }
                }
            }
            
            if (hasChanges) {
                folderRepository.save(folder);
            }

            return ResponseEntity.status(200).build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @PostMapping(path = "tags/new")
    public ResponseEntity<?> createTag(
        @RequestBody TagDTO tagData, 
        @RequestHeader("access_token") String token) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            Long userId = tokenUtil.getUserIdFromToken(token);
            Tag newTag = new Tag();

            newTag.setTag(tagData.getTag());
            tagRepository.save(newTag);

            long tag_id = newTag.getId();

            tagRepository.saveTagsUsers(tag_id, userId);

            for (long note_id : tagData.getIdOfNotesInTag()) {
                Optional<Note> temp = noteRepository.findById(Long.valueOf(note_id));
                if (temp.isPresent()) {
                    if (temp.get().getUserId() == userId) {
                        tagRepository.saveNotesTags(tag_id, note_id);
                    }
                }
            }

            return ResponseEntity.status(200).body(Collections.singletonMap("tag_id", newTag.getId()));
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @DeleteMapping(path = "delete/note")
    public ResponseEntity<?> deleteNote(
        @RequestHeader("access_token") String token,
        @RequestHeader("note_id") Long note_id
    ) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            Note note = noteRepository.findNoteByIdAndUserId(tokenUtil.getUserIdFromToken(token), note_id);
            if (note == null) {
                return ResponseEntity.status(400).body("Note id is invalid");
            }

            noteRepository.delete(note);
            return ResponseEntity.ok().body(null);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

    @DeleteMapping(path = "delete/folder")
    public ResponseEntity<?> deleteFolder(
        @RequestHeader("access_token") String token,
        @RequestHeader("folder_id") Long folder_id
    ) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).body("Access token is invalid");
            }

            Folder folder = folderRepository.findFolderByIdAndUserId(tokenUtil.getUserIdFromToken(token), folder_id);
            if (folder == null) {
                return ResponseEntity.status(400).body("Folder id is invalid");
            }

            folderRepository.delete(folder);
            return ResponseEntity.ok().body(null);
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }


    @GetMapping(path = "refresh/tokens")
    public ResponseEntity<?> refreshToken(
        @CookieValue(value = "refresh_token") String raw_refresh_token,
        HttpServletResponse response
    ) {
        String refresh_token = raw_refresh_token.replace("refresh_token=", "");
        try {
            if (refresh_token == null || !tokenUtil.validateToken(refresh_token)) {
                return ResponseEntity.status(401).location(URI.create("login/")).build();
            }

            String newRefreshToken = tokenUtil.generateRefreshToken(tokenUtil.getUserIdFromToken(refresh_token).toString());
            String newAccessToken = tokenUtil.generateAccessToken(tokenUtil.getUserIdFromToken(refresh_token).toString());

            Cookie refreshCookie = new Cookie("refresh_token", newRefreshToken);
            refreshCookie.setHttpOnly(true);
            refreshCookie.setSecure(true);
            refreshCookie.setPath("/");
            refreshCookie.setMaxAge(7 * 24 * 60 * 60);

            response.addCookie(refreshCookie);

            return ResponseEntity
                .status(200)
                .header("access_token", newAccessToken)
                .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong On Server :(");
        }
    }

}
