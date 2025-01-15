package ai.notiva.app.entities;

import java.sql.Timestamp;

import jakarta.persistence.*;

@Entity
@Table(name = "notes")
public class Note{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "notes_name", nullable = false)
    private String notes_name;

    @Column(name = "summary", nullable = false)
    private String summary;

    @Column(name = "transcript", nullable = false)
    private String transcript;

    @Column(name = "audio", nullable = false)
    private String audio;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "time_of_creation", nullable = false)
    private Timestamp time_of_creation;

    @Column(name = "time_of_last_changes", nullable = false)
    private Timestamp time_of_last_changes;

    @Column(name = "icon", nullable = false)
    private String icon;

    @Column(name = "is_favourite", nullable = false)
    private boolean is_favourite;

    @Column(name = "is_everyone_can_access", nullable = false)
    private boolean is_everyone_can_access;

    public Long getId() {
        return id;
    };

    public String getNotes_name() {
        return notes_name;
    };

    public String getSummary() {
        return summary;
    }

    public String getTranscript() {
        return transcript;
    }

    public String getAudio() {
        return audio;
    }
    
    public Long getUserId() {
        return userId;
    }

    public Timestamp getTime_of_creation() {
        return time_of_creation;
    }

    public Timestamp getTime_of_last_changes() {
        return time_of_last_changes;
    }

    public String getIcon() {
        return icon;
    }

    public boolean getIsFavourite() {
        return is_favourite;
    }

    public boolean getIsEveryoneCanAccess() {
        return is_everyone_can_access;
    }

    public void setNotes_name(String notes_name) {
        this.notes_name = notes_name;
    };

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public void setTranscript(String transcript) {
        this.transcript = transcript;
    }

    public void setAudio(String audio) {
        this.audio = audio;
    }
    
    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public void setTime_of_creation(Timestamp time_of_creation) {
        this.time_of_creation = time_of_creation;
    }

    public void setTime_of_last_changes(Timestamp time_of_last_changes) {
        this.time_of_last_changes = time_of_last_changes;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public void setIsFavourite(boolean is_favourite) {
        this.is_favourite = is_favourite;
    }

    public void setIsEveryoneCanAccess(boolean is_everyone_can_access) {
        this.is_everyone_can_access = is_everyone_can_access;
    }

}

