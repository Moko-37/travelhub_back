package org.travelhub.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

import org.travelhub.entities.Offer;

public class Offerdto {
    
      public record Response(
            UUID id,
            UUID branchId,
            String branchName,
            String title,
            String description,
            String destination,
            LocalDate startDate,
            LocalDate endDate,
            BigDecimal price,
            String currency,
            Integer capacity,
            Integer seatsTaken,
            Offer.OfferStatus status,
            Instant createdAt
    ) {}
 
    // Création par une branche (branchId vient du contexte authentifié)
    public record Create(
            String title,
            String description,
            String destination,
            LocalDate startDate,
            LocalDate endDate,
            BigDecimal price,
            String currency,
            Integer capacity
    ) {}
 
    public record Update(
            String title,
            String description,
            String destination,
            LocalDate startDate,
            LocalDate endDate,
            BigDecimal price,
            Integer capacity
    ) {}
 
    // Résumé léger pour les listes de recherche
    public record Summary(
            UUID id,
            String title,
            String destination,
            LocalDate startDate,
            LocalDate endDate,
            BigDecimal price,
            String currency,
            Integer capacity,
            Integer seatsTaken,
            Offer.OfferStatus status
    ) {}
}
