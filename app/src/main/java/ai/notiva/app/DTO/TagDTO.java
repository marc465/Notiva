package ai.notiva.app.DTO;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TagDTO {
    private String tag;

    @JsonProperty("idOfNotesInTag")
    private long[] idOfNotesInTag;

    private int count_notes;

    @Override
    public String toString() {
        return String.format("Tag{tag: '%s', notesInTag: %s, count_notes: %d}", tag, idOfNotesInTag.toString(), count_notes);
    }

}
