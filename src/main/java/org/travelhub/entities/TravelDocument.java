package org.travelhub.entities;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UuidGenerator;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.UUID;

// Nommée TravelDocument (et non "Document") pour éviter tout conflit
// avec java.io ou d'autres classes "Document" du JDK / des libs.
@Entity
@Table(name = "documents")
public class TravelDocument extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @UuidGenerator
    public UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "itinerary_id", nullable = false)
    public Itinerary itinerary;

    @Column(nullable = false)
    public String name;

    @Column(name = "file_url", nullable = false)
    public String fileUrl;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "document_type")
    public DocumentType type = DocumentType.other;

    @Column(name = "uploaded_at", nullable = false, updatable = false)
    public Instant uploadedAt;

    public enum DocumentType {
        ticket, voucher, invoice, other
    }
}