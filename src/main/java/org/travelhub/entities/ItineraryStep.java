package org.travelhub.entities;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import org.hibernate.annotations.UuidGenerator;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "itinerary_steps")
public class ItineraryStep extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @UuidGenerator
    public UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "itinerary_id", nullable = false)
    public Itinerary itinerary;

    @Column(nullable = false)
    public String title;

    @Column(columnDefinition = "TEXT")
    public String description;

    public String location;

    @Column(name = "step_date")
    public LocalDate stepDate;

    @Column(name = "order_index", nullable = false)
    public Integer orderIndex = 0;

    @Column(name = "created_at", nullable = false, updatable = false)
    public Instant createdAt;
}