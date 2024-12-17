package ai.notiva.app.DTO;

import java.sql.Timestamp;


public class NoteDTO {

    private String notes_name;
    private String summary;
    private String transcript;
    private String audio;
    private Timestamp time_of_creation;
    private Timestamp time_of_last_changes;
    private String icon;
    private boolean is_favourite;
    private boolean is_everyone_can_access;

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

    public String getAudio() {
        return audio;
    }

    public void setAudio(String audio) {
        this.audio = audio;
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

    public boolean isIs_favourite() {
        return is_favourite;
    }

    public void setIs_favourite(boolean is_favourite) {
        this.is_favourite = is_favourite;
    }

    public boolean isIs_everyone_can_access() {
        return is_everyone_can_access;
    }

    public void setIs_everyone_can_access(boolean is_everyone_can_access) {
        this.is_everyone_can_access = is_everyone_can_access;
    }

}
