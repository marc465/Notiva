package ai.notiva.app.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "chatbot_history_messages")
public class Message {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "message", nullable = false)
    private String message;

    @Column(name = "sender", nullable = false)
    private boolean sender;

    @Column(name = "note_id", nullable = false)
    private Long noteId;


    public Long getId() {
        return id;
    }

    public String getMessage() {
        return message;
    }

    public boolean getSender() {
        return sender;
    }

    public Long getNote() {
        return noteId;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setSender(boolean sender) {
        this.sender = sender;
    }

    public void setNoteId(Long noteId) {
        this.noteId = noteId;
    }

    @Override
    public String toString() {
        return "Message{" +
                "id=" + id +
                ", message='" + message + '\'' +
                ", sender='" + sender + '\'' +
                '}';
    }
}
