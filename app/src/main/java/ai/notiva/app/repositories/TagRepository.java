package ai.notiva.app.repositories;

import ai.notiva.app.entities.Tag;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TagRepository extends JpaRepository<Tag, Long>{

    @Query(value = """
    SELECT t.* FROM tags t
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
 
}
