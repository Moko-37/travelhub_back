# TravelHub — API Backend

API centrale de **TravelHub**, plateforme de mise en relation entre voyageurs et agences de voyage, pensée pour le marché camerounais.

> Projet de portfolio — Douala, Cameroun

## À propos

TravelHub digitalise la réservation de voyages : les agences publient leurs offres depuis un espace dédié, les voyageurs recherchent et réservent directement, et chaque réservation confirmée génère un carnet de voyage numérique (itinéraire, documents, statut).

## Stack technique

| Composant | Technologie |
|---|---|
| Framework | Quarkus (Java) |
| ORM | Hibernate ORM avec Panache |
| Base de données | PostgreSQL |
| Migrations | Flyway |
| Authentification | OpenID Connect (Keycloak) |
| Documentation API | SmallRye OpenAPI |

## Modules fonctionnels

- **Users** — comptes, rôles (voyageur / agence / admin), authentification
- **Agencies** — profils d'agences, statut de validation par l'administrateur
- **Agency Branches** — branches/succursales d'une agence, chacune publiant ses propres offres
- **Offers** — offres de voyage publiées par les branches, réservables directement
- **Bookings** — réservations directes d'une offre
- **Itineraries** — carnet de voyage lié à une réservation confirmée
- **Itinerary Steps** — étapes chronologiques du voyage
- **Documents** — billets, vouchers, factures liés au voyage
- **Reviews** — avis des voyageurs sur les agences
- **Notifications** — événements clés (réservation confirmée, offre publiée...)

## Prérequis

- JDK 17+
- Maven (ou le wrapper `./mvnw` fourni)
- PostgreSQL (local ou Docker)
- Keycloak (pour l'authentification OIDC)

## Installation

```bash
git clone https://github.com/TON_USERNAME/travelhub-backend.git
cd travelhub-backend
```

## Configuration

Copie les variables d'environnement nécessaires (voir `application.yaml`) :

```bash
export DB_USERNAME=postgres
export DB_PASSWORD=postgres
export DB_URL=jdbc:postgresql://localhost:5432/travelhub
```

## Lancer le projet en développement

```bash
./mvnw quarkus:dev
```

L'API démarre par défaut sur `http://localhost:8080`.
Dev UI disponible sur `http://localhost:8080/q/dev/`.

## Migrations de base de données

Les migrations sont gérées par Flyway, dans `src/main/resources/db/migration/`.
Elles s'exécutent automatiquement au démarrage (`migrate-at-start: true`).

## Build pour la production

```bash
./mvnw package
java -jar target/quarkus-app/quarkus-run.jar
```

## Architecture

Le backend suit une approche modulaire, avec une séparation claire entre entités du domaine et couche d'accès aux données via **Panache**, dans la continuité des choix d'architecture appliqués sur les autres projets (Tontine, Zeradon).

## Périmètre (MVP)

- Inscription / authentification par rôle
- Publication et recherche d'offres, gérées par branche d'agence
- Réservation directe d'une offre publiée
- Carnet de voyage : étapes, documents, statut
- Dashboard agence : offres, réservations par branche

**Hors périmètre (V2)** : paiement en ligne (Mobile Money), messagerie temps réel, génération d'itinéraires par IA, facturation comptable.

## Auteur

Yvan — Douala, Cameroun