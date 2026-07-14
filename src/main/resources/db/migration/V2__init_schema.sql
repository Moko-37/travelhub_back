-- ============================================================
-- TravelHub - Ajout de la colonne keycloak_id
-- Fichier : src/main/resources/db/migration/V2__add_keycloak_id_to_users.sql
-- ============================================================

ALTER TABLE users
    ADD COLUMN keycloak_id VARCHAR(255);

-- Contrainte d'unicité séparée (équivalent à @Column(unique = true) côté entité)
ALTER TABLE users
    ADD CONSTRAINT uk_users_keycloak_id UNIQUE (keycloak_id);