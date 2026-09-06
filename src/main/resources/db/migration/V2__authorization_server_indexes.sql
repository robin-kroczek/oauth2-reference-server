CREATE UNIQUE INDEX ux_registered_client_client_id
    ON oauth2_registered_client (client_id);

CREATE INDEX ix_authorization_access_token
    ON oauth2_authorization USING hash (access_token_value);

CREATE INDEX ix_authorization_refresh_token
    ON oauth2_authorization USING hash (refresh_token_value);

CREATE INDEX ix_authorization_access_token_expires
    ON oauth2_authorization (access_token_expires_at);

CREATE INDEX ix_authorization_client
    ON oauth2_authorization (registered_client_id);