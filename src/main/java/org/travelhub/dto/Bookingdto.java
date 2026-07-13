package org.travelhub.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

import org.travelhub.entities.Booking;

public class Bookingdto {
    
     public record Response(
            UUID id,
            UUID userId,
            UUID offerId,
            String offerTitle,
            UUID branchId,
            String branchName,
            BigDecimal totalPrice,
            String currency,
            Integer travelersCount,
            Booking.BookingStatus status,
            Instant bookedAt
    ) {}
 
    // Création par un voyageur (userId vient du token authentifié)
    public record Create(
            UUID offerId,
            Integer travelersCount
    ) {}
 
    // Mise à jour du statut par l'agence
    public record UpdateStatus(
            Booking.BookingStatus status
    ) {}
}
