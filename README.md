# oauth2-reference-server

This is an OAuth 2.1 authorization server for machine-to-machine authorization. 
It deliberately does not implement OpenID Connect or end-user login: running a user-facing identity provider means owning password storage, recovery, MFA and session management, which is a product in its own right. Use Keycloak for that.