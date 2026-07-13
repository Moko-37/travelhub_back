package org.travelhub.dto;

import java.time.LocalDate;
import java.util.UUID;

public class ItineraryStepdto {
       public record Response(
            UUID id,
            UUID itineraryId,
            String title,
            String description,
            String location,
            LocalDate stepDate,
            Integer orderIndex
    ) {}
 
    public record Create(
            String title,
            String description,
            String location,
            LocalDate stepDate,
            Integer orderIndex
    ) {}
 
    public record Update(
            String title,
            String description,
            String location,
            LocalDate stepDate,
            Integer orderIndex
    ) {}
}
