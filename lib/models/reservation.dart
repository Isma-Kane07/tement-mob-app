import 'package:flutter/material.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/models/user.dart';

class Reservation {
  final int id;
  final int logementId;
  final int locataireId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final double montantTotal;
  final String statut;
  final Logement? logement;
  final User? locataire;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reservation({
    required this.id,
    required this.logementId,
    required this.locataireId,
    required this.dateDebut,
    required this.dateFin,
    required this.montantTotal,
    required this.statut,
    this.logement,
    this.locataire,
    this.createdAt,
    this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      logementId: json['logement_id'] ?? 0,
      locataireId: json['locataire_id'] ?? 0,
      dateDebut: DateTime.parse(
          json['date_debut'] ?? DateTime.now().toIso8601String()),
      dateFin:
          DateTime.parse(json['date_fin'] ?? DateTime.now().toIso8601String()),
      montantTotal: (json['montant_total'] ?? 0).toDouble(),
      statut: json['statut'] ?? 'en_attente',
      logement:
          json['Logement'] != null ? Logement.fromJson(json['Logement']) : null,
      locataire: json['Utilisateur'] != null
          ? User.fromJson(json['Utilisateur'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  String get statutEnFrancais {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'confirme':
        return 'Confirmée';
      case 'paye': // ✅ AJOUTER CE CAS
        return 'Paiement confirmé';
      case 'annule':
        return 'Annulée';
      default:
        return statut;
    }
  }

  Color get statutCouleur {
    switch (statut) {
      case 'en_attente':
        return Colors.orange;
      case 'confirme':
        return Colors.green;
      case 'paye': // ✅ AJOUTER CE CAS
        return Colors.purple;
      case 'annule':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get estPaye => statut == 'paye'; // ✅ AJOUTER CETTE PROPRIÉTÉ

  int get nombreNuits {
    return dateFin.difference(dateDebut).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logement_id': logementId,
      'locataire_id': locataireId,
      'date_debut': dateDebut.toIso8601String().split('T')[0],
      'date_fin': dateFin.toIso8601String().split('T')[0],
      'montant_total': montantTotal,
      'statut': statut,
    };
  }
}
