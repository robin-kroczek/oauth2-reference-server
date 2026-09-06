-- Derived from Spring Authorization Server 1.5.x:
--   org/springframework/security/oauth2/server/authorization/
--     oauth2-authorization-schema.sql
--   org/springframework/security/oauth2/server/authorization/client/
--     oauth2-registered-client-schema.sql
--
-- Licensed under the Apache License, Version 2.0.
-- See the NOTICE file for the full attribution and the list of changes.
--
-- Adapted for PostgreSQL as instructed by the header of the original files:
--   blob      -> text
--   timestamp -> timestamptz  (otherwise instants are stored inaccurately)
--
-- Unused columns (oidc_*, user_code_*, device_code_*, redirect_uris) are kept
-- on purpose: JdbcOAuth2AuthorizationService and JdbcRegisteredClientRepository
-- build their statements from fixed column lists, so removing them would
-- require custom mappers.
--
-- When upgrading the authorization server, diff this file against the
-- originals shipped with the new version.
CREATE TABLE oauth2_registered_client
(
    id                            varchar(100)  NOT NULL,
    client_id                     varchar(100)  NOT NULL,
    client_id_issued_at           timestamptz   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    client_secret                 varchar(200)           DEFAULT NULL,
    client_secret_expires_at      timestamptz            DEFAULT NULL,
    client_name                   varchar(200)  NOT NULL,
    client_authentication_methods varchar(1000) NOT NULL,
    authorization_grant_types     varchar(1000) NOT NULL,
    redirect_uris                 varchar(1000)          DEFAULT NULL,
    post_logout_redirect_uris     varchar(1000)          DEFAULT NULL,
    scopes                        varchar(1000) NOT NULL,
    client_settings               varchar(2000) NOT NULL,
    token_settings                varchar(2000) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE oauth2_authorization
(
    id                            varchar(100) NOT NULL,
    registered_client_id          varchar(100) NOT NULL,
    principal_name                varchar(200) NOT NULL,
    authorization_grant_type      varchar(100) NOT NULL,
    authorized_scopes             varchar(1000) DEFAULT NULL,
    attributes                    text          DEFAULT NULL,
    state                         varchar(500)  DEFAULT NULL,
    authorization_code_value      text          DEFAULT NULL,
    authorization_code_issued_at  timestamptz   DEFAULT NULL,
    authorization_code_expires_at timestamptz   DEFAULT NULL,
    authorization_code_metadata   text          DEFAULT NULL,
    access_token_value            text          DEFAULT NULL,
    access_token_issued_at        timestamptz   DEFAULT NULL,
    access_token_expires_at       timestamptz   DEFAULT NULL,
    access_token_metadata         text          DEFAULT NULL,
    access_token_type             varchar(100)  DEFAULT NULL,
    access_token_scopes           varchar(1000) DEFAULT NULL,
    oidc_id_token_value           text          DEFAULT NULL,
    oidc_id_token_issued_at       timestamptz   DEFAULT NULL,
    oidc_id_token_expires_at      timestamptz   DEFAULT NULL,
    oidc_id_token_metadata        text          DEFAULT NULL,
    refresh_token_value           text          DEFAULT NULL,
    refresh_token_issued_at       timestamptz   DEFAULT NULL,
    refresh_token_expires_at      timestamptz   DEFAULT NULL,
    refresh_token_metadata        text          DEFAULT NULL,
    user_code_value               text          DEFAULT NULL,
    user_code_issued_at           timestamptz   DEFAULT NULL,
    user_code_expires_at          timestamptz   DEFAULT NULL,
    user_code_metadata            text          DEFAULT NULL,
    device_code_value             text          DEFAULT NULL,
    device_code_issued_at         timestamptz   DEFAULT NULL,
    device_code_expires_at        timestamptz   DEFAULT NULL,
    device_code_metadata          text          DEFAULT NULL,
    PRIMARY KEY (id)
);