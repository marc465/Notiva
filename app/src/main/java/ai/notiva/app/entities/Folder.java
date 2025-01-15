package ai.notiva.app.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "folders")
public class Folder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "folder_name", nullable = false)
    private String folder_name;
    
    @Column(name = "icon", nullable = false)
    private String icon;

    @Column(name = "user_id", nullable = false)
    private Long user;

    public long getId() {
        return id;
    }
    
    public void setId(long id) {
        this.id = id;
    }

    public String getFolder_name() {
        return folder_name;
    }
    
    public void setFolder_name(String folder_name) {
        this.folder_name = folder_name;
    }
    
    public String getIcon() {
        return icon;
    }
    
    public void setIcon(String icon) {
        this.icon = icon;
    }
    
    public Long getUserId() {
        return user;
    }
    
    public void setUserId(Long user) {
        this.user = user;
    }
    
    @Override
    public String toString() {
        return String.format("Folder{id: %d, folder_name: '%s', icon: '%s', user_id: %d}", id, folder_name, icon, user);
    }
    
}
