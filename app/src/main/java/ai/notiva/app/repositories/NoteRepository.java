package ai.notiva.app.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import ai.notiva.app.entities.Note;
import java.util.List;

public interface NoteRepository extends JpaRepository<Note, Long>{

    @Query(value = """
    SELECT * FROM public.notes
    WHERE user_id = :user_id
            """, nativeQuery = true)
    List<Note> findByUser_id(@Param("user_id") Long user_id);

    @Query(value = """
    SELECT id, notes_name, summary, transcript, audio, user_id, time_of_creation, time_of_last_changes, icon, is_favourite, is_everyone_can_access
    FROM public.notes
    WHERE user_id = :user_id
    AND search @@ phraseto_tsquery(':query')
    ORDER BY ts_rank(search, phraseto_tsquery(':query')) desc;
            """, nativeQuery = true)
    List<Note> fulltextSearch(@Param("user_id") Long user_id, @Param("query") String query);

    @Query(value = """
    SELECT n.* FROM public.notes n
    INNER JOIN notes_tags nt ON n.id = nt.note_id
    WHERE n.user_id = :user_id
    AND nt.tag_id IN (
        SELECT id FROM tags
        WHERE tag ILIKE '%:tag%'
    )
        """, nativeQuery = true)
    List<Note> findNotesByUserIdAndTag(@Param("user_id") Long user_id, @Param("tag") String tag);

    @Query(value = """
    SELECT * FROM public.notes
    WHERE user_id = :user_id
    AND is_favourite = true
    ORDER BY notes_name;
        """, nativeQuery = true)
    List<Note> findNotesByUserIdAndFavourite(@Param("user_id") Long user_id);

}
