package org.travelhub.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class Itinerarydto {
    

      public record Response(
            UUID id,
            UUID bookingId,
            String notes,
            List<ItineraryStepdto.Response> steps,
            List<Traveldocumentdto.Response> documents,
            Instant createdAt
    ) {}
 
    public record UpdateNotes(
            String notes
    ) {}
}
