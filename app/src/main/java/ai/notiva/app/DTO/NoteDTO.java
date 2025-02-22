package ai.notiva.app.DTO;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
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
}
