package ai.notiva.app.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "folders")
public class Folder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "folder_name", nullable = false)
    private String folder_name;

    @Column(name = "description", nullable = true)
    private String description;
    
    @Column(name = "icon", nullable = false)
    private String icon;

    @Column(name = "user_id", nullable = false)
    private Long user;
    
    // @Column(name = "count_notes", nullable = false)
    // private int count_notes;

    @Override
    public String toString() {
        return String.format("Folder{id: %d, folder_name: '%s', folder_description: '%s', icon: '%s'}", id, folder_name, description, icon);
    }
    
}
