package ai.notiva.app;

import ai.notiva.app.DTO.FolderDTO;
import ai.notiva.app.DTO.NoteDTO;
import ai.notiva.app.DTO.NoteForReviewDTO;
import ai.notiva.app.DTO.TagDTO;
import ai.notiva.app.DTO.QuickNote;
import ai.notiva.app.Requsts.CreateAccountRequest;
import ai.notiva.app.Requsts.LoginRequest;
import ai.notiva.app.entities.Folder;
import ai.notiva.app.entities.Note;
import ai.notiva.app.entities.Tag;
import ai.notiva.app.entities.User;
import ai.notiva.app.repositories.FolderRepository;
import ai.notiva.app.repositories.NoteRepository;
import ai.notiva.app.repositories.TagRepository;
import ai.notiva.app.repositories.UserRepository;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.net.URI;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.mpatric.mp3agic.Mp3File;

@RestController
public class NotivaAppController {

    private final JwtTokenUtil tokenUtil;
    private final TagRepository tagRepository;
    private final UserRepository userRepository;
    private final NoteRepository noteRepository;
    private final FolderRepository folderRepository;
    private final ServiceLayer service;
    private AudioSessionManager audioSessions;


    @Autowired
    public NotivaAppController(NoteRepository noteRepository, JwtTokenUtil tokenUtil, FolderRepository folderRepository, UserRepository userRepository, TagRepository tagRepository, ServiceLayer service, AudioSessionManager audioSessions) {
        this.tokenUtil = tokenUtil;
        this.tagRepository = tagRepository;
        this.noteRepository = noteRepository;
        this.userRepository = userRepository;
        this.folderRepository = folderRepository;
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
    public ResponseEntity<?> signup(@RequestBody CreateAccountRequest createAccountRequest, HttpServletResponse response) {
        try {
            String username = createAccountRequest.getUsername();
            String password = createAccountRequest.getPassword();
            String email = createAccountRequest.getEmail();

            if (!service.validateUserCredentials(username, password, email)) {
                return ResponseEntity
                    .status(400)
                    .body("Incorrect credential");
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

                
                return ResponseEntity.ok().build();
            }
            return ResponseEntity.status(409).body("User with this email or username exists");
        } catch (Exception e) {
            return ResponseEntity
                .status(500)
                .body("Something Went Wrong :(");
        }
    }

    @PostMapping(path = "/login")
    public ResponseEntity<?> postLoginPage(@RequestBody LoginRequest loginRequest,HttpServletResponse response) {
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
                return ResponseEntity
                    .status(200)
                    .body("about:blank");
            }
            return ResponseEntity
                .status(401)
                .body("Invalid username or password");
        } catch (Exception e) {
            return ResponseEntity
                .status(500)
                .body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "/notes/get")
    public ResponseEntity<?>  getNotesList(@RequestHeader("access_token") String token, HttpServletResponse response) {
        try {
            System.out.println(tokenUtil.validateToken(token));
            System.out.println(token);
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(noteRepository.findQuickNoteByUser_id(tokenUtil.getUserIdFromToken(token)));
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "/get/notes")
                .location(URI.create("/refresh/token"))
                .build();

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "/folders/get")
    public ResponseEntity<?> getFoldersList(@RequestHeader("access_token") String token, HttpServletResponse response) {
        try {
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(folderRepository.findQuickFolderByUser_id(tokenUtil.getUserIdFromToken(token)));
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "/get/folders")
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "/favourites/get")
    public ResponseEntity<?> getFavouritesList(@RequestHeader("access_token") String token, HttpServletResponse response) {
        try {
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(noteRepository.findQuickFavouriteNotesByUserIdAndFavourite(tokenUtil.getUserIdFromToken(token)));
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "/get/favourites")
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "/tags/get")
    public ResponseEntity<?> getTagsList(@RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(tagRepository.findAllByUserId(tokenUtil.getUserIdFromToken(token)));
            }
            return ResponseEntity.status(400).body("null");
            // return ResponseEntity
            //     .status(307)
            //     .header("redirect_uri", "tags/get")
            //     .location(URI.create("/refresh/token"))
            //     .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "note/view")
    public ResponseEntity<?> getNote(
        @RequestHeader("access_token") String token, 
        @RequestHeader("note_id") Long note_id, 
        HttpServletResponse response) {
            System.out.println("in note/view");

        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).location((URI.create("refresh/token"))).body("Access token is invalid.");
            }

            Note note = noteRepository.findNoteByIdAndUserId(tokenUtil.getUserIdFromToken(token), note_id);

            File file = new File(note.getAudio());
            System.out.println("opened a file");
            Mp3File mfile = new Mp3File(file);
            System.out.println("opened a mp3 file");


            NoteForReviewDTO noteForReview = new NoteForReviewDTO(note, file.length(), mfile.getBitrate());
            System.out.println("created note for review");
            System.out.println(noteForReview);


            return ResponseEntity.ok().body(noteForReview);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "note/audio")
    public ResponseEntity<?> getNoteAudio(
        @RequestHeader("access_token") String token,
        @RequestHeader("note_id") Long noteId,
        @RequestHeader(value = "range", required = false) String range,
        HttpServletResponse response) {
        try {
            System.out.println("in notes/audio");

            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).location(URI.create("refresh/token")).body("Access token is invalid.");
            }

            System.out.println("token is valid");
    
            Long userId = tokenUtil.getUserIdFromToken(token);
            Note note = noteRepository.findNoteByIdAndUserId(userId, noteId);

            System.out.println(note);
            System.out.println(userId);
            System.out.println(noteId);
            System.out.println(note.getIcon());
            System.out.println(note.getUserId());
            System.out.println(note.getUserId() == userId);
            System.out.println(note.getUserId().equals(userId));

            if (note == null || !(note.getUserId().equals(userId))) {
                return ResponseEntity.status(400).body("Wrong note id.");
            }

            System.out.println(note == null || !(note.getUserId().equals(userId)));
            System.out.println(audioSessions.getAllSessions());
    
            String key = userId + " " + noteId;
            if (audioSessions.getSession(key) == null) {
                return ResponseEntity.status(400).body("Session isn't initialized.");
            }

            System.out.println(key);
            System.out.println(audioSessions);
    

            File audioFile = new File(note.getAudio());
            long fileLength = audioFile.length();

            long start;
            long end;
            
            System.out.println("cross line with files");
            System.out.println(range);
            System.out.println(fileLength);

            if (range != null) {
                long[] startEnd = service.validateRanges(range, fileLength);
                start = startEnd[0];
                end = startEnd[1];
            System.out.println("in if expresion");
                
            } else {
                long maxRange = (48000 * 90) / 8; // 1.5 minute = 90 seconds
                start = 0;
                end = Math.min(fileLength, start + maxRange);
    
                System.out.println("in else expresion");

            }

            System.out.println(start);
            System.out.println(end);



            long contentLength = end - start;
            System.out.println(contentLength);
    
            response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            response.setHeader(HttpHeaders.CONTENT_TYPE, "audio/mpeg");
            response.setHeader(HttpHeaders.CONTENT_RANGE, "bytes=" + start + "-" + end + "/" + fileLength);
            response.setHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(fileLength));
            // response.setHeader("duration", String.valueOf((int) ((fileLength * 8) / 48000)));
            // response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + audioFile.getName() + "\"");
    
            try (RandomAccessFile raf = new RandomAccessFile(audioFile, "r");
                OutputStream outputStream = response.getOutputStream()) {

                System.out.println("in output stream");
                System.out.println(raf.length());
                raf.seek(start);
                byte[] buffer = new byte[8192]; // 65 KB буфер
                int bytesReaded;
                long bytesToWrite = contentLength;

                while ((bytesReaded = raf.read(buffer, 0, (int) Math.min(buffer.length, bytesToWrite))) > 0) {
                    System.out.println("new buff block");
                    if (audioSessions.getSession(key).isPaused()) {
                        break;
                    }
                    System.out.println(buffer.length);
                    System.out.println(bytesReaded);
                    outputStream.write(buffer, 0, bytesReaded);
                    outputStream.flush();
                    bytesToWrite -= bytesReaded;
                    System.out.println(bytesToWrite);
                }
            }
            return null; // Response is handled by streaming
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something went wrong :(");
        }
    }

    @GetMapping(path = "folder/view")
    public ResponseEntity<?> getFolder(@RequestHeader("access_token") String token, @RequestHeader("folder_id") Long folder_id, HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).location((URI.create("refresh/token"))).body("Access token is invalid.");
            }

            List<QuickNote> notes = folderRepository.findNotesInFolderByNoteIdAndUserId(tokenUtil.getUserIdFromToken(token), folder_id);

            return ResponseEntity.ok().body(notes);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "tag/view")
    public ResponseEntity<?> getTag(@RequestHeader("access_token") String token, @RequestHeader("tag_id") Long tag_id, HttpServletResponse response) {
        try {
            if (!tokenUtil.validateToken(token)) {
                return ResponseEntity.status(401).location((URI.create("refresh/token"))).body("Access token is invalid.");
            }

            List<QuickNote> notes = tagRepository.findNotesByTagIdAndUserId(tokenUtil.getUserIdFromToken(token), tag_id);

            return ResponseEntity.ok().body(notes);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "notes/searsh")
    public ResponseEntity<?> searchInNotes(@RequestParam("q") String q, @RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(noteRepository.fulltextSearch(tokenUtil.getUserIdFromToken(token), q));
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "notes/searsh?q=" + q)
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "folders/searsh")
    public ResponseEntity<?> searchInFolders(@RequestParam("q") String q, @RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(folderRepository.fulltextSearch(tokenUtil.getUserIdFromToken(token), q));
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "notes/searsh?q=" + q)
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "tags/searsh")
    public ResponseEntity<?> searchInTags(@RequestParam("q") String q, @RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(tagRepository.fulltextSearch(tokenUtil.getUserIdFromToken(token), q));
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "notes/searsh?q=" + q)
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @PostMapping(path = "notes/new")
    public ResponseEntity<?> createNote(@RequestBody NoteDTO noteData, @RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {

                Long user_id = tokenUtil.getUserIdFromToken(token);

                Note newNote = new Note();
                newNote.setNotes_name(noteData.getNotes_name());
                newNote.setTranscript(noteData.getTranscript());
                newNote.setTime_of_creation(Timestamp.valueOf(LocalDateTime.now()));
                newNote.setTime_of_last_changes(Timestamp.valueOf(LocalDateTime.now()));
                newNote.setUserId(userRepository.findById(user_id).get().getId());
                newNote.setAudio(service.saveAudio(user_id, noteData.getNotes_name(), noteData.getAudio()));
                newNote.setSummary(service.generateSummary(noteData.getTranscript()));
                newNote.setIcon(service.generateIcon(noteData.getNotes_name()));
                newNote.setIsFavourite(false);
                newNote.setIsEveryoneCanAccess(false);

                noteRepository.save(newNote);

                return ResponseEntity
                    .status(200)
                    .build();
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "notes/new")
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @PostMapping(path = "folders/new")
    public ResponseEntity<?> createFolder(@RequestBody FolderDTO folderData, @RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {

                Long userId = userRepository.findById(tokenUtil.getUserIdFromToken(token)).get().getId();
                Folder newFolder = new Folder();

                newFolder.setFolder_name(folderData.getfolderName());
                newFolder.setIcon(folderData.getIcon());
                newFolder.setUserId(userId);

                folderRepository.save(newFolder);
                long folder_id = newFolder.getId();

                for (long note_id : folderData.getNotesInFolder()) {
                    Optional<Note> temp = noteRepository.findById(Long.valueOf(note_id));
                    if (temp.isPresent()) {
                        if (temp.get().getUserId() == userId) {
                            folderRepository.saveNotesIdToNotes_Folders(folder_id, note_id);
                        }
                    }
                }

                return ResponseEntity
                    .status(200)
                    .build();
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "folders/new")
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @PostMapping(path = "tags/new")
    public ResponseEntity<?> createTag(@RequestBody TagDTO tagData, @RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {

                Long userId = userRepository.findById(tokenUtil.getUserIdFromToken(token)).get().getId();
                Tag newTag = new Tag();

                newTag.setTag(tagData.getTag());
                tagRepository.save(newTag);

                long tag_id = newTag.getId();

                tagRepository.saveTagsUsers(tag_id, userId);

                for (long note_id : tagData.getNotesInTag()) {
                    Optional<Note> temp = noteRepository.findById(Long.valueOf(note_id));
                    if (temp.isPresent()) {
                        if (temp.get().getUserId() == userId) {
                            tagRepository.saveNotesTags(tag_id, note_id);
                        }
                    }
                }

                return ResponseEntity
                    .status(200)
                    .build();
            }
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "tags/new")
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "refresh/token")
    public ResponseEntity<?> refreshToken(
                @CookieValue(value = "refresh_token", required = false) String refresh_token,
                @RequestHeader(value = "redirect_uri", defaultValue = "/get/notes") String redirectUri,
                HttpServletResponse response) {
        try {
            if (refresh_token == null) {
                response.sendRedirect("/login");
                return null;
            }
            if (tokenUtil.validateToken(refresh_token)) {
                String newRefreshToken = tokenUtil.generateRefreshToken(refresh_token);
                String newAccessToken = tokenUtil.generateAccessToken(refresh_token);

                Cookie refreshCookie = new Cookie("refresh_token", newRefreshToken);
                refreshCookie.setHttpOnly(true);
                refreshCookie.setSecure(true);
                refreshCookie.setPath("/");
                refreshCookie.setMaxAge(7 * 24 * 60 * 60);

                response.addCookie(refreshCookie);

                return ResponseEntity
                    .status(302)
                    .header("access_token", newAccessToken)
                    .location(URI.create(redirectUri))
                    .build();
            }
            response.sendRedirect("/login");
            return null;
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

}
