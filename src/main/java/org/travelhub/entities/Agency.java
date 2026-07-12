package org.travelhub.entities;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UuidGenerator;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "agencies")
public class Agency extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @UuidGenerator
    public UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    public User user;

    @Column(name = "company_name", nullable = false)
    public String companyName;

    @Column(columnDefinition = "TEXT")
    public String description;

    public String address;

    public String city;

    @Column(name = "registration_no")
    public String registrationNo;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "agency_status")
    public AgencyStatus status = AgencyStatus.pending;

    @Column(name = "created_at", nullable = false, updatable = false)
    public Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    public Instant updatedAt;

    @OneToMany(mappedBy = "agency", cascade = CascadeType.ALL)
    public List<AgencyBranch> branches;

    @OneToMany(mappedBy = "agency")
    public List<Review> reviews;

    public enum AgencyStatus {
        pending, approved, rejected, suspended
    }
}
