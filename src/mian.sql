-- =========================================================
-- TravelHub — Schéma de base de données (PostgreSQL)
-- Version alignée sur le cahier des charges : 9 entités
-- (le système requests/quotes a été retiré du périmètre)
-- =========================================================

-- Extension pour la génération d'UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------
-- ENUMS
-- ---------------------------------------------------------
CREATE TYPE user_role AS ENUM ('traveler', 'agency', 'admin');
CREATE TYPE agency_status AS ENUM ('pending', 'approved', 'rejected', 'suspended');
CREATE TYPE offer_status AS ENUM ('draft', 'pending_review', 'published', 'archived');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
CREATE TYPE document_type AS ENUM ('ticket', 'voucher', 'invoice', 'other');
CREATE TYPE notification_type AS ENUM (
  'booking_confirmed', 'booking_cancelled', 'offer_published', 'agency_approved'
);

-- ---------------------------------------------------------
-- USERS
-- ---------------------------------------------------------
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           VARCHAR(255) NOT NULL UNIQUE,
  password_hash   VARCHAR(255) NOT NULL,
  full_name       VARCHAR(150) NOT NULL,
  phone           VARCHAR(30),
  role            user_role NOT NULL DEFAULT 'traveler',
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_role ON users(role);

-- ---------------------------------------------------------
-- AGENCIES
-- Relation : users 1—1 agencies
-- ---------------------------------------------------------
CREATE TABLE agencies (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  company_name    VARCHAR(150) NOT NULL,
  description     TEXT,
  address         VARCHAR(255),
  city            VARCHAR(100),
  registration_no VARCHAR(100),
  status          agency_status NOT NULL DEFAULT 'pending',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_agencies_status ON agencies(status);

-- ---------------------------------------------------------
-- AGENCY_BRANCHES
-- Relation : agencies 1—N agency_branches
-- Une agence peut posséder plusieurs branches (agences locales,
-- points de vente). Chaque branche gère ses propres offres.
-- ---------------------------------------------------------
CREATE TABLE agency_branches (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id       UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  name            VARCHAR(150) NOT NULL,
  address         VARCHAR(255),
  city            VARCHAR(100),
  phone           VARCHAR(30),
  is_main         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_agency_branches_agency ON agency_branches(agency_id);
CREATE INDEX idx_agency_branches_city ON agency_branches(city);

-- ---------------------------------------------------------
-- OFFERS
-- Relation : agency_branches 1—N offers
-- Une branche publie et gère ses propres offres.
-- ---------------------------------------------------------
CREATE TABLE offers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id       UUID NOT NULL REFERENCES agency_branches(id) ON DELETE CASCADE,
  title           VARCHAR(200) NOT NULL,
  description     TEXT,
  destination     VARCHAR(150) NOT NULL,
  start_date      DATE NOT NULL,
  end_date        DATE NOT NULL,
  price           NUMERIC(12,2) NOT NULL CHECK (price >= 0),
  currency        VARCHAR(3) NOT NULL DEFAULT 'XAF',
  capacity        INTEGER NOT NULL CHECK (capacity > 0),
  seats_taken     INTEGER NOT NULL DEFAULT 0 CHECK (seats_taken >= 0),
  status          offer_status NOT NULL DEFAULT 'draft',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_date >= start_date),
  CHECK (seats_taken <= capacity)
);

CREATE INDEX idx_offers_branch ON offers(branch_id);
CREATE INDEX idx_offers_destination ON offers(destination);
CREATE INDEX idx_offers_status ON offers(status);
CREATE INDEX idx_offers_dates ON offers(start_date, end_date);

-- ---------------------------------------------------------
-- BOOKINGS
-- Relations : users 1—N bookings | offers 1—N bookings | agency_branches 1—N bookings
-- Réservation directe sur une offre publiée par une branche.
-- ---------------------------------------------------------
CREATE TABLE bookings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  offer_id        UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
  branch_id       UUID NOT NULL REFERENCES agency_branches(id) ON DELETE CASCADE,
  total_price     NUMERIC(12,2) NOT NULL CHECK (total_price >= 0),
  currency        VARCHAR(3) NOT NULL DEFAULT 'XAF',
  travelers_count INTEGER NOT NULL DEFAULT 1 CHECK (travelers_count > 0),
  status          booking_status NOT NULL DEFAULT 'pending',
  booked_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_offer ON bookings(offer_id);
CREATE INDEX idx_bookings_branch ON bookings(branch_id);
CREATE INDEX idx_bookings_status ON bookings(status);

-- ---------------------------------------------------------
-- ITINERARIES (carnet de voyage — 1—1 avec bookings)
-- ---------------------------------------------------------
CREATE TABLE itineraries (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id      UUID NOT NULL UNIQUE REFERENCES bookings(id) ON DELETE CASCADE,
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------
-- ITINERARY_STEPS (étapes du voyage)
-- Relation : itineraries 1—N itinerary_steps
-- ---------------------------------------------------------
CREATE TABLE itinerary_steps (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  itinerary_id    UUID NOT NULL REFERENCES itineraries(id) ON DELETE CASCADE,
  title           VARCHAR(200) NOT NULL,
  description     TEXT,
  location        VARCHAR(200),
  step_date       DATE,
  order_index     INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_itinerary_steps_itinerary ON itinerary_steps(itinerary_id, order_index);

-- ---------------------------------------------------------
-- DOCUMENTS (billets, vouchers, factures liés au voyage)
-- Relation : itineraries 1—N documents
-- ---------------------------------------------------------
CREATE TABLE documents (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  itinerary_id    UUID NOT NULL REFERENCES itineraries(id) ON DELETE CASCADE,
  name            VARCHAR(200) NOT NULL,
  file_url        VARCHAR(500) NOT NULL,
  type            document_type NOT NULL DEFAULT 'other',
  uploaded_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_documents_itinerary ON documents(itinerary_id);

-- ---------------------------------------------------------
-- REVIEWS (avis voyageur sur une agence après un voyage)
-- Relations : bookings 1—1 reviews | agencies 1—N reviews
-- ---------------------------------------------------------
CREATE TABLE reviews (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id      UUID NOT NULL UNIQUE REFERENCES bookings(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  agency_id       UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  rating          SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment         TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_reviews_agency ON reviews(agency_id);

-- ---------------------------------------------------------
-- NOTIFICATIONS
-- Relation : users 1—N notifications
-- ---------------------------------------------------------
CREATE TABLE notifications (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type            notification_type NOT NULL,
  message         VARCHAR(500) NOT NULL,
  is_read         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

-- ---------------------------------------------------------
-- TRIGGER GÉNÉRIQUE : mise à jour automatique de updated_at
-- ---------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_agencies_updated_at BEFORE UPDATE ON agencies
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_agency_branches_updated_at BEFORE UPDATE ON agency_branches
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_offers_updated_at BEFORE UPDATE ON offers
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_bookings_updated_at BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_itineraries_updated_at BEFORE UPDATE ON itineraries
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();