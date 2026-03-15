import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/services/api_service.dart';

class LogementService {
  final ApiService _apiService = ApiService();

  // ✅ MODIFIÉ : Récupérer les logements avec filtres optionnels
  Future<List<Logement>> getLogements({
    String? search,
    String? type,
    double? minPrix,
    double? maxPrix,
    int? proprietaireId,
  }) async {
    try {
      // Construire les paramètres de requête
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (minPrix != null) queryParams['minPrix'] = minPrix;
      if (maxPrix != null) queryParams['maxPrix'] = maxPrix;
      if (proprietaireId != null)
        queryParams['proprietaire_id'] = proprietaireId;

      final response = await _apiService.get(
        ApiConstants.logements,
        queryParams: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Logement.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getLogements: $e');
      throw Exception('Impossible de charger les logements');
    }
  }

  // ✅ NOUVEAU : Désactiver/Activer un logement
  Future<Logement> desactiverLogement(int id, bool disponible) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.logements}/$id/desactiver',
        data: {'disponible': disponible},
      );

      return Logement.fromJson(response.data['logement']);
    } catch (e) {
      print('❌ Erreur desactiverLogement: $e');
      throw Exception('Impossible de modifier le statut du logement');
    }
  }

  // Récupérer un logement par ID
  Future<Logement> getLogementById(int id) async {
    try {
      final response = await _apiService.get('${ApiConstants.logements}/$id');
      return Logement.fromJson(response.data);
    } catch (e) {
      print('❌ Erreur getLogementById: $e');
      throw Exception('Logement non trouvé');
    }
  }

  // Créer un logement
  Future<Logement> creerLogement({
    required String type,
    required String adresse,
    required String description,
    required double prixNuit,
    List<String> photos = const [],
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.logements,
        data: {
          'type': type,
          'adresse': adresse,
          'description': description,
          'prix_nuit': prixNuit,
          'photos': photos,
        },
      );

      return Logement.fromJson(response.data['logement']);
    } catch (e) {
      print('❌ Erreur creerLogement: $e');
      throw Exception('Impossible de créer le logement');
    }
  }

  // Modifier un logement
  Future<Logement> modifierLogement({
    required int id,
    String? type,
    String? adresse,
    String? description,
    double? prixNuit,
    List<String>? photos,
    bool? disponible,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.logements}/$id',
        data: {
          if (type != null) 'type': type,
          if (adresse != null) 'adresse': adresse,
          if (description != null) 'description': description,
          if (prixNuit != null) 'prix_nuit': prixNuit,
          if (photos != null) 'photos': photos,
          if (disponible != null) 'disponible': disponible,
        },
      );

      return Logement.fromJson(response.data['logement']);
    } catch (e) {
      print('❌ Erreur modifierLogement: $e');
      throw Exception('Impossible de modifier le logement');
    }
  }

  // Supprimer un logement
  Future<void> supprimerLogement(int id) async {
    try {
      await _apiService.delete('${ApiConstants.logements}/$id');
    } catch (e) {
      print('❌ Erreur supprimerLogement: $e');
      throw Exception('Impossible de supprimer le logement');
    }
  }
}
