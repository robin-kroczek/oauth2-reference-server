package de.rkroczek.auth.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.ApplicationPidFileWriter;

@SpringBootApplication
public class SpringAuthorizationServerApplication {

    static void main(String[] args) {
        SpringApplication springApplication = new SpringApplication(SpringAuthorizationServerApplication.class);
        springApplication.addListeners(new ApplicationPidFileWriter());
        springApplication.run(args);
    }

}
