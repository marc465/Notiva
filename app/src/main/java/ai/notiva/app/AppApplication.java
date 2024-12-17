package ai.notiva.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;


@SpringBootApplication(exclude = { SecurityAutoConfiguration.class })
@ComponentScan(basePackages = "ai.notiva.app")
public class AppApplication {

	
	public static void main(String[] args) {
		SpringApplication.run(AppApplication.class, args);
	}

}
