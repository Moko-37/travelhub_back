package org.travelhub.entities;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UuidGenerator;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "notifications")
public class Notification extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @UuidGenerator
    public UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    public User user;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "notification_type")
    public NotificationType type;

    @Column(nullable = false)
    public String message;

    @Column(name = "is_read", nullable = false)
    public boolean isRead = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    public Instant createdAt;

    public enum NotificationType {
        booking_confirmed, booking_cancelled, offer_published, agency_approved
    }
}
