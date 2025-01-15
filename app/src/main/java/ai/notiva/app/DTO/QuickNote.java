package ai.notiva.app.DTO;

import java.sql.Timestamp;

public interface QuickNote {
    Long getId();
    String getNotes_name();
    String getTranscript();
    Timestamp getTime_of_creation();
    Timestamp getTime_of_last_changes();
    String getIcon();
    boolean getIs_favourite();
}