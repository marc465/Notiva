package ai.notiva.app.DTO;

import ai.notiva.app.entities.Note;
import java.sql.Timestamp;
import java.io.IOException;

public class NoteForReviewDTO {

    private Long id;
    private String notes_name;
    private String summary;
    private String transcript;
    private Long userId;
    private Timestamp time_of_creation;
    private Timestamp time_of_last_changes;
    private String icon;
    private boolean is_favourite;
    private boolean is_everyone_can_access;
    private long audioFileSize;
    private int bps;

    public NoteForReviewDTO(Note note, long fileSize, int bps) throws IOException {
        this.id = note.getId();
        this.notes_name = note.getNotes_name();
        this.summary = note.getSummary();
        this.transcript = note.getTranscript();
        this.userId = note.getUserId();
        this.time_of_creation = note.getTime_of_creation();
        this.time_of_last_changes = note.getTime_of_last_changes();
        this.icon = note.getIcon();
        this.is_favourite = note.getIsFavourite();
        this.is_everyone_can_access = note.getIsEveryoneCanAccess();
        this.audioFileSize = fileSize;
        this.bps = bps;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNotes_name() {
        return notes_name;
    }

    public void setNotes_name(String notes_name) {
        this.notes_name = notes_name;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getTranscript() {
        return transcript;
    }

    public void setTranscript(String transcript) {
        this.transcript = transcript;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Timestamp getTime_of_creation() {
        return time_of_creation;
    }

    public void setTime_of_creation(Timestamp time_of_creation) {
        this.time_of_creation = time_of_creation;
    }

    public Timestamp getTime_of_last_changes() {
        return time_of_last_changes;
    }

    public void setTime_of_last_changes(Timestamp time_of_last_changes) {
        this.time_of_last_changes = time_of_last_changes;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public boolean getIs_favourite() {
        return is_favourite;
    }

    public void setIs_favourite(boolean is_favourite) {
        this.is_favourite = is_favourite;
    }

    public boolean getIs_everyone_can_access() {
        return is_everyone_can_access;
    }

    public void setIs_everyone_can_access(boolean is_everyone_can_access) {
        this.is_everyone_can_access = is_everyone_can_access;
    }

    public long getAudioFileSize() {
        return audioFileSize;
    }

    public void setAudioFileSize(long fileSize) {
        this.audioFileSize = fileSize;
    }

    public int getBps() {
        return bps;
    }

    public void setBps(int bps) {
        this.bps = bps;
    }

    @Override
    public String toString() {
        return "NoteForReviewDTO{" +
                "id=" + id +
                ", notes_name='" + notes_name + '\'' +
                ", summary='" + summary + '\'' +
                ", transcript='" + transcript + '\'' +
                ", time_of_creation=" + time_of_creation +
                ", time_of_last_changes=" + time_of_last_changes +
                ", icon='" + icon + '\'' +
                ", is_favourite=" + is_favourite +
                ", is_everyone_can_access=" + is_everyone_can_access +
                ", size=" + audioFileSize +
                ", bps=" + bps +
                '}';
    }

}
