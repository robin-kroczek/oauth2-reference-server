package de.rkroczek.auth.server.config;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.HttpHeaders;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {"management.endpoints.web.exposure.include=health,info,env", "management.endpoint.health.probes.enabled=true", "management.server.port=8080"})
public class SecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("/actuator/health is reachable without authentication")
    void healthEndpointIsPublic() throws Exception {
        mockMvc.perform(get("/actuator/health")).andExpect(status().isOk());
    }

    @Test
    @DisplayName("/actuator/health/** is reachable without authentication")
    void healthSubPathsArePublic() throws Exception {
        mockMvc.perform(get("/actuator/health/liveness")).andExpect(status().isOk());

        mockMvc.perform(get("/actuator/health/readiness")).andExpect(status().isOk());
    }

    @Test
    @DisplayName("other actuator endpoints are denied for anonymous users")
    void otherActuatorEndpointsAreProtected() throws Exception {
        mockMvc.perform(get("/actuator/info")).andExpect(status().isForbidden());

        mockMvc.perform(get("/actuator/env")).andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser
    @DisplayName("other actuator endpoints are reachable once authenticated")
    void otherActuatorEndpointsAreOpenForAuthenticatedUsers() throws Exception {
        mockMvc.perform(get("/actuator/info")).andExpect(status().isOk());
    }

    @Test
    @DisplayName("httpBasic is disabled: no WWW-Authenticate challenge is sent")
    void noBasicAuthChallenge() throws Exception {
        mockMvc.perform(get("/actuator/env")).andExpect(status().isForbidden()).andExpect(header().doesNotExist(HttpHeaders.WWW_AUTHENTICATE));
    }

    @Test
    @DisplayName("formLogin is disabled: no redirect to a login page")
    void noRedirectToLoginPage() throws Exception {
        mockMvc.perform(get("/actuator/env")).andExpect(status().isForbidden()).andExpect(header().doesNotExist(HttpHeaders.LOCATION));
    }
}
