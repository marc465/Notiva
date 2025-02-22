package ai.notiva.app.entities;

import java.sql.Timestamp;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter
@Setter
@Entity
@Table(name = "notes")
public class Note {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "notes_name", nullable = false)
    private String notes_name;

    @Column(name = "summary", nullable = false)
    private String summary;

    @Column(name = "transcript", nullable = false)
    private String transcript;

    @Column(name = "summary_jsonb", columnDefinition = "jsonb", nullable = false)
    @JdbcTypeCode(SqlTypes.JSON)
    private String summary_jsonb;

    @Column(name = "transcript_jsonb", columnDefinition = "jsonb", nullable = false)
    @JdbcTypeCode(SqlTypes.JSON)
    private String transcript_jsonb;

    @Column(name = "audio", nullable = true)
    private String audio;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "time_of_creation", nullable = false)
    private Timestamp time_of_creation;

    @Column(name = "time_of_last_changes", nullable = false)
    private Timestamp time_of_last_changes;

    @Column(name = "icon", nullable = false)
    private String icon;

    @Column(name = "is_favourite", nullable = false)
    private boolean is_favourite;

    @Column(name = "is_everyone_can_access", nullable = false)
    private boolean is_everyone_can_access;
}