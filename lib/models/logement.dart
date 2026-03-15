import 'package:tement_mobile/models/user.dart';

class Logement {
  final int id;
  final int proprietaireId;
  final String type;
  final String adresse;
  final String? description;
  final double prixNuit;
  final List<String> photos;
  final bool disponible;
  final User? proprietaire;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Statistiques (optionnelles)
  final double? noteMoyenne;
  final int? nombreAvis;

  Logement({
    required this.id,
    required this.proprietaireId,
    required this.type,
    required this.adresse,
    this.description,
    required this.prixNuit,
    required this.photos,
    required this.disponible,
    this.proprietaire,
    this.createdAt,
    this.updatedAt,
    this.noteMoyenne,
    this.nombreAvis,
  });

  factory Logement.fromJson(Map<String, dynamic> json) {
    return Logement(
      id: json['id'] ?? 0,
      proprietaireId: json['proprietaire_id'] ?? 0,
      type: json['type'] ?? 'maison',
      adresse: json['adresse'] ?? '',
      description: json['description'],
      prixNuit: (json['prix_nuit'] ?? 0).toDouble(),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],
      disponible: json['disponible'] ?? true,
      proprietaire: json['Utilisateur'] != null
          ? User.fromJson(json['Utilisateur'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      noteMoyenne: json['note_moyenne']?.toDouble(),
      nombreAvis: json['nombre_avis'],
    );
  }

  String get typeEnFrancais {
    switch (type) {
      case 'maison':
        return 'Maison';
      case 'appartement':
        return 'Appartement';
      case 'studio':
        return 'Studio';
      default:
        return type;
    }
  }

  String get formattedPrix {
    return '${prixNuit.toStringAsFixed(0)} FCFA';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proprietaire_id': proprietaireId,
      'type': type,
      'adresse': adresse,
      'description': description,
      'prix_nuit': prixNuit,
      'photos': photos,
      'disponible': disponible,
    };
  }
}
