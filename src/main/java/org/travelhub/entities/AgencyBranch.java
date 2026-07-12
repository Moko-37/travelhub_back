package org.travelhub.entities;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import org.hibernate.annotations.UuidGenerator;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "agency_branches")
public class AgencyBranch extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @UuidGenerator
    public UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agency_id", nullable = false)
    public Agency agency;

    @Column(nullable = false)
    public String name;

    public String address;

    public String city;

    public String phone;

    @Column(name = "is_main", nullable = false)
    public boolean isMain = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    public Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    public Instant updatedAt;

    @OneToMany(mappedBy = "branch", cascade = CascadeType.ALL)
    public List<Offer> offers;

    @OneToMany(mappedBy = "branch")
    public List<Booking> bookings;
}
