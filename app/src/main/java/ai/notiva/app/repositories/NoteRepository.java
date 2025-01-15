package ai.notiva.app.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import ai.notiva.app.entities.Note;
import ai.notiva.app.DTO.QuickNote;
import java.util.List;

public interface NoteRepository extends JpaRepository<Note, Long>{

    @Query(value = """
        SELECT
            id AS id,
            notes_name AS notes_name, 
            SUBSTRING(transcript FROM 1 FOR 50) || '...' AS transcript, 
            time_of_creation AS time_of_creation, 
            time_of_last_changes AS time_of_last_changes,
            icon AS icon, 
            is_favourite AS is_favourite
        FROM public.notes
        WHERE user_id = :user_id;
            """, nativeQuery = true)
    List<QuickNote> findQuickNoteByUser_id(@Param("user_id") Long user_id);

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
        SELECT 
            id AS id,
            notes_name AS notes_name, 
            SUBSTRING(transcript FROM 1 FOR 50) || '...' AS transcript, 
            time_of_creation AS time_of_creation, 
            time_of_last_changes AS time_of_last_changes,
            icon AS icon, 
            is_favourite AS is_favourite
        FROM public.notes
        WHERE user_id = :user_id
        AND is_favourite = true
        ORDER BY notes_name;
            """, nativeQuery = true)
    List<QuickNote> findQuickFavouriteNotesByUserIdAndFavourite(@Param("user_id") Long user_id);

    @Query(value = """
        SELECT * FROM public.notes
        WHERE id = :note_id
        AND user_id = :user_id
        LIMIT 1;
            """, nativeQuery = true)
    Note findNoteByIdAndUserId(@Param("user_id") Long user_id, @Param("note_id") Long note_id);

}
