package ai.notiva.app;

import ai.notiva.app.DTO.FolderDTO;
import ai.notiva.app.DTO.NoteDTO;
import ai.notiva.app.DTO.TagDTO;
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

import java.net.URI;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class NotivaAppController {

    private final JwtTokenUtil tokenUtil;
    private final TagRepository tagRepository;
    private final UserRepository userRepository;
    private final NoteRepository noteRepository;
    private final FolderRepository folderRepository;
    private final ServiceLayer service;

    @Autowired
    public NotivaAppController(NoteRepository noteRepository, JwtTokenUtil tokenUtil, FolderRepository folderRepository, UserRepository userRepository, TagRepository tagRepository, ServiceLayer service) {
        this.tokenUtil = tokenUtil;
        this.tagRepository = tagRepository;
        this.noteRepository = noteRepository;
        this.userRepository = userRepository;
        this.folderRepository = folderRepository;
        this.service = service;
    }
    
    @GetMapping(path = "/")
    public String homePage() {
        return "Hello Notiva!";
    }

    @GetMapping(path = "/login")
    public String loginPage() {
        return "login";
    }

    @PostMapping(path = "/create")
    public ResponseEntity<?> createAccount(@RequestBody CreateAccountRequest createAccountRequest, HttpServletResponse response) {
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

                response.sendRedirect("/login");
                return null;
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
                response.sendRedirect("/get/notes");

                return null;
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
            if (tokenUtil.validateToken(token)) {
                return ResponseEntity
                    .status(200)
                    .body(noteRepository.findByUser_id(tokenUtil.getUserIdFromToken(token)));
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
                    .body(folderRepository.findAllByUserId(tokenUtil.getUserIdFromToken(token)));
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
                    .body(noteRepository.findNotesByUserIdAndFavourite(tokenUtil.getUserIdFromToken(token)));
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
            return ResponseEntity
                .status(307)
                .header("redirect_uri", "/get/tags")
                .location(URI.create("/refresh/token"))
                .build();
        } catch (Exception e) {
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
                newNote.setUser(userRepository.findById(user_id).get());
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

                Folder newFolder = new Folder();
                newFolder.setFolder_name(folderData.getFolder_name());
                newFolder.setIcon(service.generateIcon(folderData.getFolder_name()));
                newFolder.setUser(userRepository.findById(tokenUtil.getUserIdFromToken(token)).get());

                folderRepository.save(newFolder);

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
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @PostMapping(path = "tags/new")
    public ResponseEntity<?> createTag(@RequestBody TagDTO tagData, @RequestHeader("access_token") String token) {
        try {
            if (tokenUtil.validateToken(token)) {

                Tag newTag = new Tag();
                newTag.setTag(tagData.getTag());

                tagRepository.save(newTag);

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
            return ResponseEntity.status(500).body("Something Went Wrong :(");
        }
    }

    @GetMapping(path = "/refresh/token")
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
