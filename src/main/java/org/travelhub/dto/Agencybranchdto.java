package org.travelhub.dto;

import java.time.Instant;
import java.util.UUID;


public class Agencybranchdto {
    
     public record Response(
            UUID id,
            UUID agencyId,
            String name,
            String address,
            String city,
            String phone,
            boolean isMain,
            Instant createdAt
    ) {}
 
    public record Create(
            String name,
            String address,
            String city,
            String phone,
            boolean isMain
    ) {}
 
    public record Update(
            String name,
            String address,
            String city,
            String phone,
            boolean isMain
    ) {}
}
