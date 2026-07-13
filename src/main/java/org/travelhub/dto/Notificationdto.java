package org.travelhub.dto;
import org.travelhub.entities.Notification;

import java.time.Instant;
import java.util.UUID;

public class Notificationdto {
    
     public record Response(
            UUID id,
            UUID userId,
            Notification.NotificationType type,
            String message,
            boolean isRead,
            Instant createdAt
    ) {}
 
    public record MarkAsRead(
            boolean isRead
    ) {}
}
