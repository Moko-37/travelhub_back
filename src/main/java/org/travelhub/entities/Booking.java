package org.travelhub.entities;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UuidGenerator;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "bookings")
public class Booking extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @UuidGenerator
    public UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    public User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "offer_id", nullable = false)
    public Offer offer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id", nullable = false)
    public AgencyBranch branch;

    @Column(name = "total_price", nullable = false, precision = 12, scale = 2)
    public BigDecimal totalPrice;

    @Column(nullable = false, length = 3)
    public String currency = "XAF";

    @Column(name = "travelers_count", nullable = false)
    public Integer travelersCount = 1;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "booking_status")
    public BookingStatus status = BookingStatus.pending;

    @Column(name = "booked_at", nullable = false, updatable = false)
    public Instant bookedAt;

    @Column(name = "updated_at", nullable = false)
    public Instant updatedAt;

    @OneToOne(mappedBy = "booking", cascade = CascadeType.ALL)
    public Itinerary itinerary;

    @OneToOne(mappedBy = "booking", cascade = CascadeType.ALL)
    public Review review;

    public enum BookingStatus {
        pending, confirmed, cancelled, completed
    }
}