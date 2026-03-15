import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/services/api_service.dart';

class WalletService {
  final ApiService _apiService = ApiService();

  // Récupérer l'historique du wallet
  Future<Map<String, dynamic>> getHistoriqueWallet() async {
    try {
      final response = await _apiService.get(ApiConstants.wallet);

      return {
        'solde_actuel': response.data['solde_actuel']?.toDouble() ?? 0,
        'stats': response.data['stats'] ?? {},
        'transactions': response.data['transactions'] ?? [],
      };
    } catch (e) {
      print('❌ Erreur getHistoriqueWallet: $e');
      throw Exception('Impossible de charger l\'historique');
    }
  }

  // Demander un retrait (propriétaire)
  Future<Map<String, dynamic>> demanderRetrait({
    required double montant,
    String methodeRetrait = 'orange_money',
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.retraits}/demander',
        data: {
          'montant': montant,
          'methode_retrait': methodeRetrait,
        },
      );

      return Map<String, dynamic>.from(response.data['demande']);
    } catch (e) {
      print('❌ Erreur demanderRetrait: $e');
      throw Exception('Impossible de demander le retrait');
    }
  }

  // Récupérer l'historique des retraits (propriétaire)
  Future<List<Map<String, dynamic>>> getHistoriqueRetraits() async {
    try {
      final response =
          await _apiService.get('${ApiConstants.retraits}/historique');

      if (response.data['retraits'] != null) {
        return List<Map<String, dynamic>>.from(response.data['retraits']);
      }
      return [];
    } catch (e) {
      print('❌ Erreur getHistoriqueRetraits: $e');
      throw Exception('Impossible de charger l\'historique');
    }
  }

  // Admin: Lister les retraits en attente
  Future<List<Map<String, dynamic>>> getRetraitsEnAttente() async {
    try {
      final response =
          await _apiService.get('${ApiConstants.retraits}/en-attente');

      if (response.data['retraits'] != null) {
        return List<Map<String, dynamic>>.from(response.data['retraits']);
      }
      return [];
    } catch (e) {
      print('❌ Erreur getRetraitsEnAttente: $e');
      throw Exception('Impossible de charger les retraits');
    }
  }

  // Admin: Valider un retrait
  Future<void> validerRetrait(int transactionId,
      {String? referenceVirement}) async {
    try {
      await _apiService.post(
        '${ApiConstants.retraits}/valider',
        data: {
          'transaction_id': transactionId,
          'reference_virement': referenceVirement,
        },
      );
    } catch (e) {
      print('❌ Erreur validerRetrait: $e');
      throw Exception('Impossible de valider le retrait');
    }
  }

  // Admin: Refuser un retrait
  Future<void> refuserRetrait(int transactionId, {String? raison}) async {
    try {
      await _apiService.post(
        '${ApiConstants.retraits}/refuser',
        data: {
          'transaction_id': transactionId,
          'raison': raison,
        },
      );
    } catch (e) {
      print('❌ Erreur refuserRetrait: $e');
      throw Exception('Impossible de refuser le retrait');
    }
  }
}
