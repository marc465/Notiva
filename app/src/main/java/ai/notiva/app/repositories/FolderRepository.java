package ai.notiva.app.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import ai.notiva.app.entities.Folder;

import java.util.List;

public interface FolderRepository extends JpaRepository<Folder, Long> {

    @Query(value = """
        SELECT * FROM public.folders
        WHERE user_id = :user_id
        ORDER BY folder_name;
            """, nativeQuery = true)
    List<Folder> findAllByUserId(@Param("user_id") Long user_id);
    
    @Query(value = """
    SELECT id, folder_name, icon, user_id
    FROM public.folders
    WHERE user_id = :user_id
    AND search @@ phraseto_tsquery(':query')
    ORDER BY ts_rank(search, phraseto_tsquery(':query')) desc;
            """, nativeQuery = true)
    List<Folder> fulltextSearch(@Param("user_id") Long user_id, @Param("query") String query);

}
