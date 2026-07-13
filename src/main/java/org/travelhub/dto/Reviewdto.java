package org.travelhub.dto;

import java.time.Instant;
import java.util.UUID;

public class Reviewdto {
     public record Response(
            UUID id,
            UUID bookingId,
            UUID userId,
            String userFullName,
            UUID agencyId,
            Short rating,
            String comment,
            Instant createdAt
    ) {}
 
    // Création par le voyageur (bookingId, userId, agencyId dérivés du contexte)
    public record Create(
            Short rating,
            String comment
    ) {}
}
