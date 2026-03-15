import 'package:flutter/material.dart';

class Paiement {
  final int id;
  final int reservationId;
  final String? methode;
  final double montantTotal;
  final double commissionTement;
  final double netProprietaire;
  final String? referenceTransaction;
  final String statut;
  final DateTime? datePaiement;
  final Map<String, dynamic>? reservation;

  Paiement({
    required this.id,
    required this.reservationId,
    this.methode,
    required this.montantTotal,
    required this.commissionTement,
    required this.netProprietaire,
    this.referenceTransaction,
    required this.statut,
    this.datePaiement,
    this.reservation,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'] ?? 0,
      reservationId: json['reservation_id'] ?? 0,
      methode: json['methode'],
      montantTotal: (json['montant_total'] ?? 0).toDouble(),
      commissionTement: (json['commission_tement'] ?? 0).toDouble(),
      netProprietaire: (json['net_proprietaire'] ?? 0).toDouble(),
      referenceTransaction: json['reference_transaction'],
      statut: json['statut'] ?? 'en_attente',
      datePaiement: json['date_paiement'] != null
          ? DateTime.parse(json['date_paiement'])
          : null,
      reservation: json['Reservation'],
    );
  }

  String get statutEnFrancais {
    switch (statut) {
      case 'en_attente':
        return 'En attente de validation';
      case 'effectue':
        return 'Paiement effectué';
      case 'echoue':
        return 'Échoué';
      default:
        return statut;
    }
  }

  Color get statutCouleur {
    switch (statut) {
      case 'en_attente':
        return Colors.orange;
      case 'effectue':
        return Colors.green;
      case 'echoue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'methode': methode,
      'montant_total': montantTotal,
      'commission_tement': commissionTement,
      'net_proprietaire': netProprietaire,
      'reference_transaction': referenceTransaction,
      'statut': statut,
    };
  }
}
