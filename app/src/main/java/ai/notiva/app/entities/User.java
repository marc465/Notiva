package ai.notiva.app.entities;

import java.sql.Timestamp;
import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "username", nullable = false, unique = true)
    private String username;
    
    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "password", nullable = false)
    private String password;

    @Column(name = "vip", nullable = false)
    private boolean vip;

    @Column(name = "date_of_creation", nullable = false)
    private Timestamp date_of_creation;

    public Long getId() {
        return this.id;
    };
    
    public void setId(Long id) {
        this.id = id;
    };

    public String getUsername() {
        return this.username;
    };
    
    public void setUsername(String username) {
        this.username = username;
    };

    public String getEmail() {
        return this.email;
    };
    
    public void setEmail(String email) {
            this.email = email;
    };

    public String getPassword() {
        return this.password;
    };
    
    public void setPassword(String password) {
        this.password = password;
    };

    public boolean getVip() {
        return this.vip;
    };
    
    public void setVip(boolean vip) {
        this.vip = vip;
    };

    public Timestamp getDateOfCreation() {
        return this.date_of_creation;
    };
    
    public void setDateOfCreation(Timestamp date_of_creation) {
        this.date_of_creation = date_of_creation;
    };

}
