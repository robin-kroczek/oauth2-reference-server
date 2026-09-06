package de.rkroczek.auth.server.bootstrap;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClient;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClientRepository;
import org.springframework.security.oauth2.server.authorization.settings.TokenSettings;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.UUID;


/**
 * Creates the single administrative client that breaks the registration
 * cycle: registering a client requires a token, and obtaining a token
 * requires a client. This one is injected from the environment instead.
 *
 * <p>All further clients are created through dynamic client registration
 * (RFC 7591) using a token issued to this client.
 *
 * <p>Runs on every start and does nothing if the client already exists,
 * so it is safe to leave configured.
 */
@Component
@EnableConfigurationProperties(AdminClientProperties.class)
class AdminClientBootstrap implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(AdminClientBootstrap.class);

    private static final String ADMIN_SCOPE = "clients.write";

    private final RegisteredClientRepository clients;
    private final PasswordEncoder encoder;
    private final AdminClientProperties properties;

    AdminClientBootstrap(RegisteredClientRepository clients,
                         PasswordEncoder encoder,
                         AdminClientProperties properties) {
        this.clients = clients;
        this.encoder = encoder;
        this.properties = properties;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!properties.isConfigured()) {
            log.info("No admin client configured, skipping bootstrap");
            return;
        }
        if (clients.findByClientId(properties.clientId()) != null) {
            log.debug("Admin client '{}' already exists", properties.clientId());
            return;
        }

        clients.save(RegisteredClient.withId(UUID.randomUUID().toString())
                .clientId(properties.clientId())
                .clientSecret(encoder.encode(properties.clientSecret()))
                .clientName("Bootstrap admin client")
                .clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_BASIC)
                .authorizationGrantType(AuthorizationGrantType.CLIENT_CREDENTIALS)
                .scope(ADMIN_SCOPE)
                // Short-lived on purpose: this token can create other clients.
                .tokenSettings(TokenSettings.builder()
                        .accessTokenTimeToLive(Duration.ofMinutes(5))
                        .build())
                .build());

        log.info("Bootstrapped admin client '{}' with scope '{}'",
                properties.clientId(), ADMIN_SCOPE);
    }
}