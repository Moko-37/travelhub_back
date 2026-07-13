package org.travelhub.dto;

import org.travelhub.entities.*;

import java.time.Instant;
import java.util.UUID;

public class Userdto {

    // Réponse envoyée au client (jamais le mot de passe)
    public record Response(
            UUID id,
            String email,
            String fullName,
            String phone,
            User.UserRole role,
            boolean isActive,
            Instant createdAt
    ) {}

    // Inscription d'un nouvel utilisateur
    public record Register(
            String email,
            String password,
            String fullName,
            String phone,
            User.UserRole role
    ) {}

    // Connexion
    public record Login(
            String email,
            String password
    ) {}

    // Mise à jour du profil
    public record Update(
            String fullName,
            String phone
    ) {}
}
