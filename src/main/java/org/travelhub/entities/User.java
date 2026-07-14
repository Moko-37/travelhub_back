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
@Table(name = "users")
public class User extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @UuidGenerator
    public UUID id;

    @Column(name = "keycloak_id", unique = true)
    public String keycloakId;

    @Column(nullable = false, unique = true)
    public String email;

    @Column(name = "full_name", nullable = false)
    public String fullName;

    public String phone;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "user_role")
    public UserRole role = UserRole.traveler;

    @ManyToOne
    @JoinColumn(name = "agency_branch_id")
    public AgencyBranch agencyBranch;

    @Column(name = "is_active", nullable = false)
    public boolean isActive = true;

    @Column(name = "created_at", nullable = false, updatable = false)
    public Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    public Instant updatedAt;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    public Agency agency;

    @OneToMany(mappedBy = "user")
    public List<Booking> bookings;

    @OneToMany(mappedBy = "user")
    public List<Review> reviews;

    @OneToMany(mappedBy = "user")
    public List<Notification> notifications;

    public enum UserRole {
        traveler, agency_admin, branch_admin, admin
    }
}