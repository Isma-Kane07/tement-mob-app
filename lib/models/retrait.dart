import 'package:flutter/material.dart';

class Retrait {
  final int id;
  final int userId;
  final double montant;
  final String statut;
  final String? description;
  final DateTime? createdAt;
  final Map<String, dynamic>? utilisateur;

  Retrait({
    required this.id,
    required this.userId,
    required this.montant,
    required this.statut,
    this.description,
    this.createdAt,
    this.utilisateur,
  });

  factory Retrait.fromJson(Map<String, dynamic> json) {
    return Retrait(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      montant: (json['montant'] ?? 0).toDouble(),
      statut: json['statut'] ?? 'en_attente',
      description: json['description'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      utilisateur: json['Utilisateur'],
    );
  }

  String get statutEnFrancais {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'valide':
        return 'Validé';
      case 'refuse':
        return 'Refusé';
      default:
        return statut;
    }
  }

  Color get statutCouleur {
    switch (statut) {
      case 'en_attente':
        return Colors.orange;
      case 'valide':
        return Colors.green;
      case 'refuse':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'montant': montant,
      'statut': statut,
      'description': description,
    };
  }
}
