package ai.notiva.app.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import ai.notiva.app.DTO.QuickFolder;
import ai.notiva.app.DTO.QuickNote;
import ai.notiva.app.entities.Folder;
import jakarta.transaction.Transactional;

import java.util.List;

public interface FolderRepository extends JpaRepository<Folder, Long> {
    
    @Transactional
    @Modifying
    @Query(value = """
        INSERT INTO public.notes_folders (note_id, folder_id)
        VALUES (:note_id, :folder_id);
            """, nativeQuery = true)
    int saveNotesIdToNotes_Folders(@Param("folder_id") long folder_id, @Param("note_id") long note_id);

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
        INNER JOIN public.notes_folders nf ON n.id = nf.note_id
        WHERE nf.folder_id = :id
        AND n.user_id = :user_id
            """, nativeQuery = true)
    List<QuickNote> findNotesInFolderByNoteIdAndUserId(@Param("user_id") Long user_id, @Param("id") Long id);

    @Query(value = """
        SELECT 
            id AS id,
            folder_name AS folder_name, 
            icon AS icon
        FROM public.folders
        WHERE user_id = :user_id
            """, nativeQuery = true)
    List<QuickFolder> findQuickFolderByUser_id(@Param("user_id") Long user_id);


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
