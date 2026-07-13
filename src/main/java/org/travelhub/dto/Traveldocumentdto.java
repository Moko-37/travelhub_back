package org.travelhub.dto;

import java.time.Instant;
import java.util.UUID;

import org.travelhub.entities.TravelDocument;

public class Traveldocumentdto {
     public record Response(
            UUID id,
            UUID itineraryId,
            String name,
            String fileUrl,
            TravelDocument.DocumentType type,
            Instant uploadedAt
    ) {}
 
    public record Create(
            String name,
            String fileUrl,
            TravelDocument.DocumentType type
    ) {}
}
