package de.rkroczek.auth.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class OAuth2ReferenceServerApplication {

    static void main(String[] args) {
        SpringApplication springApplication = new SpringApplication(OAuth2ReferenceServerApplication.class);
        springApplication.run(args);
    }

}
