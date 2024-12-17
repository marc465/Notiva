package ai.notiva.app.DTO;

public class FolderDTO {
    private String folder_name;
    private String icon;
    private long user_id;
    
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
    
    public long getUser_id() {
        return user_id;
    }
    
    public void setUser_id(long user_id) {
        this.user_id = user_id;
    }
    
}
