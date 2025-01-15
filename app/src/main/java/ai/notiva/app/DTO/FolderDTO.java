package ai.notiva.app.DTO;

import com.fasterxml.jackson.annotation.JsonProperty;

public class FolderDTO {
    private String folderName;
    private String icon;
    @JsonProperty("idOfNotesInFolder")
    private long[] idOfNotesInFolder;
    
    public String getfolderName() {
        return folderName;
    }
    
    public void setfolderName(String folderName) {
        this.folderName = folderName;
    }
    
    public String getIcon() {
        return icon;
    }
    
    public void setIcon(String icon) {
        this.icon = icon;
    }

    public long[] getNotesInFolder() {
        return idOfNotesInFolder;
    }
    
    public void setNotesInFolder(long[] notesList) {
        this.idOfNotesInFolder = notesList;
    }

    @Override
    public String toString() {
        return String.format("Folder{folderName: '%s', icon: '%s', notesInFolder: %s}", folderName, icon, idOfNotesInFolder.toString());
    }

}
