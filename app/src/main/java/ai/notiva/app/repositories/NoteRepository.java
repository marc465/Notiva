package ai.notiva.app.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import ai.notiva.app.entities.Note;
import jakarta.transaction.Transactional;
import ai.notiva.app.DTO.QuickNote;

import java.util.Collection;
import java.util.List;

public interface NoteRepository extends JpaRepository<Note, Long>{

    @Modifying
    @Transactional
    @Query("UPDATE Note n SET n.audio = :audio WHERE n.id = :id")
    int updateAudio(@Param("id") Long id, @Param("audio") String audioPath);


    @Query(value = """
        SELECT
            n.id AS id,
            n.notes_name AS notes_name, 
            SUBSTRING(n.transcript FROM 1 FOR 50) || '...' AS transcript, 
            n.time_of_creation AS time_of_creation, 
            n.time_of_last_changes AS time_of_last_changes,
            n.icon AS icon, 
            n.is_favourite AS is_favourite
        FROM public.notes n
            JOIN public.notes_folders nf ON n.id = nf.note_id
        WHERE n.user_id = :user_id
        AND nf.folder_id = :folder_id
            """, nativeQuery = true)
    List<QuickNote> findNotesInsideFolder(
        @Param("user_id") Long userId,
        @Param("folder_id") Long folder_id
    );

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
        AND (COALESCE(:exceptions) IS NULL OR id NOT IN :exceptions)
            """, nativeQuery = true)
    List<QuickNote> findNotesWithExceptions(
        @Param("user_id") Long userId, 
        @Param("exceptions") Collection<Long> exceptions
    );
    
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
    SELECT
        id AS id,
        notes_name AS notes_name, 
        SUBSTRING(transcript FROM 1 FOR 50) || '...' AS transcript, 
        time_of_creation AS time_of_creation, 
        time_of_last_changes AS time_of_last_changes,
        icon AS icon, 
        is_favourite AS is_favourite
    FROM public.notes n
		JOIN public.notes_tags nt ON n.id = nt.note_id
    WHERE n.user_id = :user_id
    AND nt.tag_id = :tag_id
	AND (n.search @@ websearch_to_tsquery(:query) OR transcript ILIKE '%' || :query || '%')
    ORDER BY ts_rank(n.search, websearch_to_tsquery(:query)) desc;
            """, nativeQuery = true)
    List<QuickNote> fulltextSearchInsideTag(@Param("user_id") Long user_id, @Param("tag_id") Long tag_id, @Param("query") String query);

    @Query(value = """
    SELECT
        id AS id,
        notes_name AS notes_name, 
        SUBSTRING(transcript FROM 1 FOR 50) || '...' AS transcript, 
        time_of_creation AS time_of_creation, 
        time_of_last_changes AS time_of_last_changes,
        icon AS icon, 
        is_favourite AS is_favourite
    FROM public.notes n
		JOIN public.notes_folders nf ON n.id = nf.note_id
    WHERE n.user_id = :user_id
    AND nf.folder_id = :folder_id
	AND (n.search @@ websearch_to_tsquery(:query) OR transcript ILIKE '%' || :query || '%')
    ORDER BY ts_rank(n.search, websearch_to_tsquery(:query)) desc;
            """, nativeQuery = true)
    List<QuickNote> fulltextSearchInsideFolder(@Param("user_id") Long user_id, @Param("folder_id") Long folder_id, @Param("query") String query);

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
	AND (search @@ websearch_to_tsquery(:query) OR transcript ILIKE '%' || :query || '%')
    ORDER BY ts_rank(search, websearch_to_tsquery(:query)) desc;
            """, nativeQuery = true)
    List<QuickNote> fulltextSearch(@Param("user_id") Long user_id, @Param("query") String query);


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
	AND (search @@ websearch_to_tsquery(:query) OR transcript ILIKE '%' || :query || '%')
    ORDER BY ts_rank(search, websearch_to_tsquery(:query)) desc;
            """, nativeQuery = true)
    List<QuickNote> favouritesFulltextSearch(@Param("user_id") Long user_id, @Param("query") String query);

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
        SELECT 
            id AS id,
            notes_name AS notes_name, 
            summary AS summary, 
            transcript AS transcript, 
            summary_jsonb AS summary_jsonb, 
            transcript_jsonb AS transcript_jsonb, 
            audio AS audio,
            user_id AS user_id,
            time_of_creation AS time_of_creation, 
            time_of_last_changes AS time_of_last_changes,
            icon AS icon, 
            is_favourite AS is_favourite,
            is_everyone_can_access AS is_everyone_can_access
        FROM public.notes
        WHERE id = :note_id
        AND user_id = :user_id
        LIMIT 1;
            """, nativeQuery = true)
    Note findNoteByIdAndUserId(@Param("user_id") Long user_id, @Param("note_id") Long note_id);

}
