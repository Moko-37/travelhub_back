package org.travelhub.services;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;
import org.keycloak.OAuth2Constants;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.KeycloakBuilder;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.UsersResource;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.keycloak.representations.idm.UserRepresentation;

import java.util.Collections;
import java.util.List;

/**
 * Parle à l'API d'administration de Keycloak en utilisant le compte de service
 * du client travelhub-backend (grant_type=client_credentials).
 *
 * Prérequis côté Keycloak, sur le client travelhub-backend :
 *  - Capability config > Service accounts roles : coché
 *  - Onglet "Service accounts roles" > Assign role > client realm-management > manage-users
 */
@ApplicationScoped
public class KeycloakAdminService {

    private static final Logger LOG = Logger.getLogger(KeycloakAdminService.class);

    @ConfigProperty(name = "keycloak.admin.server-url")
    String serverUrl;

    @ConfigProperty(name = "keycloak.admin.realm")
    String realm;

    @ConfigProperty(name = "quarkus.oidc.client-id")
    String clientId;

    @ConfigProperty(name = "quarkus.oidc.credentials.secret")
    String clientSecret;

    /**
     * Crée un nouveau client Keycloak à chaque appel (léger, pas besoin de garder
     * une instance ouverte). Le token client_credentials est géré en interne
     * par la librairie.
     */
    private Keycloak adminClient() {
        return KeycloakBuilder.builder()
                .serverUrl(serverUrl)
                .realm(realm)
                .grantType(OAuth2Constants.CLIENT_CREDENTIALS)
                .clientId(clientId)
                .clientSecret(clientSecret)
                .build();
    }

    /**
     * Crée un utilisateur Keycloak avec mot de passe temporaire (changement
     * obligatoire à la première connexion) et lui assigne un rôle realm.
     *
     * @return le keycloakId (sub) du nouvel utilisateur
     */
    public String createUserWithRole(String email, String fullName, String tempPassword, String roleName) {
        try (Keycloak kc = adminClient()) {
            RealmResource realmResource = kc.realm(realm);
            UsersResource usersResource = realmResource.users();

            UserRepresentation user = new UserRepresentation();
            user.setUsername(email);
            user.setEmail(email);
            user.setFirstName(fullName);
            user.setEnabled(true);
            user.setEmailVerified(true);

            CredentialRepresentation credential = new CredentialRepresentation();
            credential.setType(CredentialRepresentation.PASSWORD);
            credential.setValue(tempPassword);
            credential.setTemporary(true);
            user.setCredentials(Collections.singletonList(credential));

            try (Response response = usersResource.create(user)) {
                if (response.getStatus() != 201) {
                    LOG.errorf("Échec création utilisateur Keycloak, statut HTTP %d", response.getStatus());
                    throw new KeycloakAdminException(
                            "Impossible de créer l'utilisateur dans Keycloak (HTTP " + response.getStatus() + ")");
                }

                String location = response.getLocation().getPath();
                String keycloakId = location.substring(location.lastIndexOf('/') + 1);

                RoleRepresentation role = realmResource.roles().get(roleName).toRepresentation();
                usersResource.get(keycloakId).roles().realmLevel().add(List.of(role));

                LOG.infof("Utilisateur Keycloak créé : %s (rôle: %s)", keycloakId, roleName);
                return keycloakId;
            }
        }
    }

    /** Supprime un utilisateur Keycloak — utile pour compenser un rollback métier. */
    public void deleteUser(String keycloakId) {
        try (Keycloak kc = adminClient()) {
            kc.realm(realm).users().get(keycloakId).remove();
        }
    }

    public static class KeycloakAdminException extends RuntimeException {
        public KeycloakAdminException(String message) {
            super(message);
        }
    }
}