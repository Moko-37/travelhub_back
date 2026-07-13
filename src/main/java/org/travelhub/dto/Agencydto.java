package org.travelhub.dto;

import org.travelhub.entities.*;

import java.time.Instant;
import java.util.UUID;

public class Agencydto {

    public record Response(
            UUID id,
            UUID userId,
            String companyName,
            String description,
            String address,
            String city,
            String registrationNo,
            Agency.AgencyStatus status,
            Instant createdAt
    ) {}

    // Création par une agence (le userId vient du token authentifié, pas du body)
    public record Create(
            String companyName,
            String description,
            String address,
            String city,
            String registrationNo
    ) {}

    // Mise à jour du statut par l'administrateur
    public record UpdateStatus(
            Agency.AgencyStatus status
    ) {}
}
