-- ============================================================
-- TravelHub - Migration initiale
-- Fichier : src/main/resources/db/migration/V1__init_schema.sql
-- ============================================================

-- Extension nécessaire pour générer des UUID côté PostgreSQL
-- (utile si tu veux un jour un DEFAULT gen_random_uuid())
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ------------------------------------------------------------
-- 1. Types ENUM
-- Noms en snake_case pour correspondre à ce que Hibernate/tes
-- entités attendent (ex: @Column(columnDefinition = "agency_status"))
-- ------------------------------------------------------------
CREATE TYPE agency_status AS ENUM ('approved', 'pending', 'rejected', 'suspended');
CREATE TYPE user_role AS ENUM ('admin', 'agency_admin', 'branch_admin', 'traveler');
CREATE TYPE offer_status AS ENUM ('archived', 'draft', 'pending_review', 'published');
CREATE TYPE booking_status AS ENUM ('cancelled', 'completed', 'confirmed', 'pending');
CREATE TYPE document_type AS ENUM ('invoice', 'other', 'ticket', 'voucher');
CREATE TYPE notification_type AS ENUM ('agency_approved', 'booking_cancelled', 'booking_confirmed', 'offer_published');

-- ------------------------------------------------------------
-- 2. Tables, dans l'ordre des dépendances
-- ------------------------------------------------------------

-- users : aucune dépendance
CREATE TABLE users (
                       id            UUID PRIMARY KEY,
                       created_at    TIMESTAMPTZ  NOT NULL,
                       updated_at    TIMESTAMPTZ  NOT NULL,
                       email         VARCHAR(255) NOT NULL UNIQUE,
                       full_name     VARCHAR(255) NOT NULL,
                       is_active     BOOLEAN      NOT NULL,
                       password_hash VARCHAR(255) NOT NULL,
                       phone         VARCHAR(255),
                       role          user_role    NOT NULL
);

-- agencies : dépend de users
CREATE TABLE agencies (
                          id               UUID PRIMARY KEY,
                          created_at       TIMESTAMPTZ    NOT NULL,
                          updated_at       TIMESTAMPTZ    NOT NULL,
                          address          VARCHAR(255),
                          city             VARCHAR(255),
                          company_name     VARCHAR(255)   NOT NULL,
                          description      TEXT,
                          registration_no  VARCHAR(255),
                          status           agency_status  NOT NULL,
                          user_id          UUID           NOT NULL UNIQUE,
                          CONSTRAINT fk_agencies_user FOREIGN KEY (user_id) REFERENCES users (id)
);

-- agency_branches : dépend de agencies
CREATE TABLE agency_branches (
                                 id          UUID PRIMARY KEY,
                                 created_at  TIMESTAMPTZ  NOT NULL,
                                 updated_at  TIMESTAMPTZ  NOT NULL,
                                 address     VARCHAR(255),
                                 city        VARCHAR(255),
                                 is_main     BOOLEAN      NOT NULL,
                                 name        VARCHAR(255) NOT NULL,
                                 phone       VARCHAR(255),
                                 agency_id   UUID         NOT NULL,
                                 CONSTRAINT fk_branches_agency FOREIGN KEY (agency_id) REFERENCES agencies (id)
);

-- offers : dépend de agency_branches
CREATE TABLE offers (
                        id           UUID PRIMARY KEY,
                        created_at   TIMESTAMPTZ    NOT NULL,
                        updated_at   TIMESTAMPTZ    NOT NULL,
                        capacity     INTEGER        NOT NULL,
                        currency     VARCHAR(3)     NOT NULL,
                        description  TEXT,
                        destination  VARCHAR(255)   NOT NULL,
                        end_date     DATE           NOT NULL,
                        start_date   DATE           NOT NULL,
                        price        NUMERIC(12,2)  NOT NULL,
                        seats_taken  INTEGER        NOT NULL,
                        status       offer_status   NOT NULL,
                        title        VARCHAR(255)   NOT NULL,
                        branch_id    UUID           NOT NULL,
                        CONSTRAINT fk_offers_branch FOREIGN KEY (branch_id) REFERENCES agency_branches (id)
);

-- bookings : dépend de agency_branches, offers, users
CREATE TABLE bookings (
                          id              UUID PRIMARY KEY,
                          booked_at       TIMESTAMPTZ    NOT NULL,
                          updated_at      TIMESTAMPTZ    NOT NULL,
                          currency        VARCHAR(3)     NOT NULL,
                          status          booking_status NOT NULL,
                          total_price     NUMERIC(12,2)  NOT NULL,
                          travelers_count INTEGER        NOT NULL,
                          branch_id       UUID           NOT NULL,
                          offer_id        UUID           NOT NULL,
                          user_id         UUID           NOT NULL,
                          CONSTRAINT fk_bookings_branch FOREIGN KEY (branch_id) REFERENCES agency_branches (id),
                          CONSTRAINT fk_bookings_offer  FOREIGN KEY (offer_id)  REFERENCES offers (id),
                          CONSTRAINT fk_bookings_user   FOREIGN KEY (user_id)   REFERENCES users (id)
);

-- itineraries : dépend de bookings
CREATE TABLE itineraries (
                             id          UUID PRIMARY KEY,
                             created_at  TIMESTAMPTZ NOT NULL,
                             updated_at  TIMESTAMPTZ NOT NULL,
                             notes       TEXT,
                             booking_id  UUID        NOT NULL UNIQUE,
                             CONSTRAINT fk_itineraries_booking FOREIGN KEY (booking_id) REFERENCES bookings (id)
);

-- itinerary_steps : dépend de itineraries
CREATE TABLE itinerary_steps (
                                 id           UUID PRIMARY KEY,
                                 created_at   TIMESTAMPTZ  NOT NULL,
                                 description  TEXT,
                                 location     VARCHAR(255),
                                 order_index  INTEGER      NOT NULL,
                                 step_date    DATE,
                                 title        VARCHAR(255) NOT NULL,
                                 itinerary_id UUID         NOT NULL,
                                 CONSTRAINT fk_steps_itinerary FOREIGN KEY (itinerary_id) REFERENCES itineraries (id)
);

-- documents : dépend de itineraries
CREATE TABLE documents (
                           id           UUID PRIMARY KEY,
                           file_url     VARCHAR(255)   NOT NULL,
                           name         VARCHAR(255)   NOT NULL,
                           type         document_type  NOT NULL,
                           uploaded_at  TIMESTAMPTZ    NOT NULL,
                           itinerary_id UUID           NOT NULL,
                           CONSTRAINT fk_documents_itinerary FOREIGN KEY (itinerary_id) REFERENCES itineraries (id)
);

-- reviews : dépend de agencies, bookings, users
CREATE TABLE reviews (
                         id          UUID PRIMARY KEY,
                         comment     TEXT,
                         created_at  TIMESTAMPTZ NOT NULL,
                         rating      SMALLINT    NOT NULL,
                         agency_id   UUID        NOT NULL,
                         booking_id  UUID        NOT NULL UNIQUE,
                         user_id     UUID        NOT NULL,
                         CONSTRAINT fk_reviews_agency  FOREIGN KEY (agency_id)  REFERENCES agencies (id),
                         CONSTRAINT fk_reviews_booking FOREIGN KEY (booking_id) REFERENCES bookings (id),
                         CONSTRAINT fk_reviews_user    FOREIGN KEY (user_id)    REFERENCES users (id)
);

-- notifications : dépend de users
CREATE TABLE notifications (
                               id          UUID PRIMARY KEY,
                               created_at  TIMESTAMPTZ        NOT NULL,
                               is_read     BOOLEAN            NOT NULL,
                               message     VARCHAR(255)       NOT NULL,
                               type        notification_type  NOT NULL,
                               user_id     UUID               NOT NULL,
                               CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users (id)
);

-- ------------------------------------------------------------
-- 3. Index utiles (facultatif mais recommandé)
-- ------------------------------------------------------------
CREATE INDEX idx_agency_branches_agency_id ON agency_branches (agency_id);
CREATE INDEX idx_offers_branch_id          ON offers (branch_id);
CREATE INDEX idx_bookings_user_id          ON bookings (user_id);
CREATE INDEX idx_bookings_offer_id         ON bookings (offer_id);
CREATE INDEX idx_notifications_user_id     ON notifications (user_id);