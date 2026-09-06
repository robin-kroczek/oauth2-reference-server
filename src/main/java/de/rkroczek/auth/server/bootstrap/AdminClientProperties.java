package de.rkroczek.auth.server.bootstrap;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Credentials for the initial administrative client.
 *
 * @param clientId     public identifier, may be blank to skip bootstrapping
 * @param clientSecret plaintext secret, hashed before it is stored
 */
@ConfigurationProperties(prefix = "bootstrap.admin-client")
public record AdminClientProperties(String clientId, String clientSecret) {

    boolean isConfigured() {
        return clientId != null && !clientId.isBlank() && clientSecret != null && !clientSecret.isBlank();
    }
}