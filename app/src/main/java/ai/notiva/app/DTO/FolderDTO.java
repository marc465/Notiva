package ai.notiva.app.DTO;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FolderDTO {
    private String folderName;
    private String folderDescription;
    private String icon;
    @JsonProperty("idOfNotesInFolder")
    private long[] idOfNotesInFolder;
    
    @Override
    public String toString() {
        return String.format("Folder{folderName: '%s', icon: '%s', notesInFolder: %s}", folderName, icon, idOfNotesInFolder.toString());
    }

}
