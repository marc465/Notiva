package ai.notiva.app.repositories;

import ai.notiva.app.DTO.QuickNote;
import ai.notiva.app.entities.Tag;
import jakarta.transaction.Transactional;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TagRepository extends JpaRepository<Tag, Long>{

    @Transactional
    @Modifying
    @Query(value = """
        INSERT INTO public.notes_tags (tag_id, note_id)
        VALUES (:tag_id, :note_id);
            """, nativeQuery = true)
    int saveNotesTags(@Param("tag_id") Long tag_id, @Param("note_id") Long note_id);

    @Transactional
    @Modifying
    @Query(value = """
        INSERT INTO public.tags_users (tag_id, user_id)
        VALUES (:tag_id, :user_id);
            """, nativeQuery = true)
    int saveTagsUsers(@Param("tag_id") Long tag_id, @Param("user_id") Long user_id);

    @Query(value = """
    SELECT t.id as id, t.tag as tag FROM tags t
    INNER JOIN tags_users tu on t.id = tu.tag_id
    WHERE user_id = :user_id
    ORDER BY t.tag
            """, nativeQuery = true)
    List<Tag> findAllByUserId(@Param("user_id") Long user_id);

    @Query(value = """
    SELECT id, tag
    FROM public.tags t
        INNER JOIN public.tags_users tu ON t.id = tu.tag_id
    WHERE user_id = :user_id
    AND search @@ phraseto_tsquery(':query')
    ORDER BY ts_rank(search, phraseto_tsquery(':query')) desc;
            """, nativeQuery = true)
    List<Tag> fulltextSearch(@Param("user_id") Long user_id, @Param("query") String query);

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
        INNER JOIN public.notes_tags nt ON n.id = nt.note_id
        WHERE nt.tag_id = :tag_id
        AND n.user_id = :user_id
            """, nativeQuery = true)
    List<QuickNote> findNotesByTagIdAndUserId(@Param("user_id") Long user_id, @Param("tag_id") Long tag_id);

    @Query(value = """
        SELECT 
            t.id as id, 
            t.tag as tag 
        FROM tags t
            INNER JOIN tags_users tu on t.id = tu.tag_id
        WHERE tu.user_id = :user_id
        AND t.id = :tag_id
            """, nativeQuery = true)
    Tag findByTagIdAndUserId(@Param("user_id") Long user_id, @Param("tag_id") Long tag_id);
 
}
