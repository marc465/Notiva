package ai.notiva.app.repositories;

import ai.notiva.app.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long>{
    User findByEmail(String email);
    User findByUsername(String username);
    User findByUsernameAndPassword(String username, String password);
}
