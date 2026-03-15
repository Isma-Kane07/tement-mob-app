import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/models/paiement.dart';
import 'package:tement_mobile/services/api_service.dart';

class PaiementService {
  final ApiService _apiService = ApiService();

  // Soumettre un paiement (locataire)
  Future<Paiement> soumettrePaiement({
    required int reservationId,
    required String methode,
    required String referenceTransaction,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.paiements}/soumettre',
        data: {
          'reservation_id': reservationId,
          'methode': methode,
          'reference_transaction': referenceTransaction,
        },
      );

      return Paiement.fromJson(response.data['paiement']);
    } catch (e) {
      print('❌ Erreur soumettrePaiement: $e');
      throw Exception('Erreur lors de la soumission du paiement');
    }
  }

  // Récupérer les paiements en attente (admin)
  Future<List<Paiement>> getPaiementsEnAttente() async {
    try {
      final response =
          await _apiService.get('${ApiConstants.paiements}/en-attente');

      if (response.data['paiements'] != null) {
        return (response.data['paiements'] as List)
            .map((p) => Paiement.fromJson(p))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getPaiementsEnAttente: $e');
      throw Exception('Impossible de charger les paiements');
    }
  }

  // Valider un paiement (admin)
  Future<void> validerPaiement(int paiementId) async {
    try {
      await _apiService.post(
        '${ApiConstants.paiements}/valider',
        data: {'paiement_id': paiementId},
      );
    } catch (e) {
      print('❌ Erreur validerPaiement: $e');
      throw Exception('Impossible de valider le paiement');
    }
  }

  // Récupérer l'historique des commissions (admin)
  Future<List<Map<String, dynamic>>> getHistoriqueCommissions() async {
    try {
      final response = await _apiService
          .get('${ApiConstants.paiements}/commissions/historique');

      if (response.data['commissions'] != null) {
        return List<Map<String, dynamic>>.from(response.data['commissions']);
      }
      return [];
    } catch (e) {
      print('❌ Erreur getHistoriqueCommissions: $e');
      throw Exception('Impossible de charger l\'historique');
    }
  }
}
