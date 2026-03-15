import 'package:flutter/material.dart';

class Transaction {
  final int id;
  final int userId;
  final String type;
  final double montant;
  final String? description;
  final String statut;
  final int? adminId;
  final DateTime? createdAt;
  final Map<String, dynamic>? utilisateur;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.montant,
    this.description,
    required this.statut,
    this.adminId,
    this.createdAt,
    this.utilisateur,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      montant: (json['montant'] ?? 0).toDouble(),
      description: json['description'],
      statut: json['statut'] ?? 'valide',
      adminId: json['admin_id'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      utilisateur: json['Utilisateur'],
    );
  }

  String get typeEnFrancais {
    switch (type) {
      case 'revenu_location':
        return 'Revenu location';
      case 'commission':
        return 'Commission Tement';
      case 'retrait':
        return 'Retrait';
      default:
        return type;
    }
  }

  Color get typeCouleur {
    switch (type) {
      case 'revenu_location':
        return Colors.green;
      case 'commission':
        return Colors.orange;
      case 'retrait':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isRevenu => type == 'revenu_location';
  bool get isCommission => type == 'commission';
  bool get isRetrait => type == 'retrait';
  bool get isEnAttente => statut == 'en_attente';
  bool get estValide => statut == 'valide';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'montant': montant,
      'description': description,
      'statut': statut,
      'admin_id': adminId,
    };
  }
}
