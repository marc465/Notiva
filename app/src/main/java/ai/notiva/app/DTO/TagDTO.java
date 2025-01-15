package ai.notiva.app.DTO;

import com.fasterxml.jackson.annotation.JsonProperty;

public class TagDTO {
    private String tag;
    @JsonProperty("idOfNotesInTag")
    private long[] idOfNotesInTag;
    
    public String getTag() {
        return tag;
    }
    
    public void setTag(String tag) {
        this.tag = tag;
    }

    public long[] getNotesInTag() {
        return idOfNotesInTag;
    }
    
    public void setNotesInTag(long[] notesList) {
        this.idOfNotesInTag = notesList;
    }

    @Override
    public String toString() {
        return String.format("Tag{tag: '%s', notesInTag: %s}", tag, idOfNotesInTag.toString());
    }

}
