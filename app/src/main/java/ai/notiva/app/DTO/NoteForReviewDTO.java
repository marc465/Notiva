package ai.notiva.app.DTO;

import ai.notiva.app.entities.Note;
import lombok.Getter;
import lombok.Setter;
import java.sql.Timestamp;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.IOException;

@Getter
@Setter
public class NoteForReviewDTO {
    private Long id;
    private String notes_name;
    // private String summary;
    // private String transcript;
    private String summary_jsonb;
    private String transcript_jsonb;
    private Long userId;
    private Timestamp time_of_creation;
    private Timestamp time_of_last_changes;
    private String icon;
    @JsonProperty("is_favourite") 
    private boolean is_favourite;
    @JsonProperty("is_everyone_can_access") 
    private boolean is_everyone_can_access;
    private long audioFileSize;
    private long bps;

    public NoteForReviewDTO(Note note, long fileSize, long bps) throws IOException {
        this.id = note.getId();
        this.notes_name = note.getNotes_name();
        // this.summary = note.getSummary();
        // this.transcript = note.getTranscript();
        this.summary_jsonb = note.getSummary_jsonb();
        this.transcript_jsonb = note.getTranscript_jsonb();
        this.userId = note.getUserId();
        this.time_of_creation = note.getTime_of_creation();
        this.time_of_last_changes = note.getTime_of_last_changes();
        this.icon = note.getIcon();
        this.is_favourite = note.is_favourite();
        this.is_everyone_can_access = note.is_everyone_can_access();
        this.audioFileSize = fileSize;
        this.bps = bps;
    }

    @Override
    public String toString() {
        return "NoteForReviewDTO{" +
                "id=" + id +
                ", notes_name='" + notes_name + '\'' +
                // ", summary='" + summary + '\'' +
                // ", transcript='" + transcript + '\'' +
                ", summary_jsonb='" + summary_jsonb + '\'' +
                ", transcript_jsonb='" + transcript_jsonb + '\'' +
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