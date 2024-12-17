package ai.notiva.app.repositories;


import java.util.List;
import ai.notiva.app.entities.Chatbot_history_messages;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ChatBotMessagesRepository extends JpaRepository<Chatbot_history_messages, Long>{
    @Query(value = """
    SELECT * FROM chatbot_history_messages
    WHERE note_id = :note_id
            """, nativeQuery = true)
    List<Chatbot_history_messages> findByUserAndNote(@Param("note_id") Long note_id);
}
