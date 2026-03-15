import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/models/retrait.dart';
import 'package:tement_mobile/services/api_service.dart';

class RetraitService {
  final ApiService _apiService = ApiService();

  // 1️⃣ Propriétaire demande un retrait
  Future<Retrait> demanderRetrait({
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

      return Retrait.fromJson(response.data['demande'] ?? response.data);
    } catch (e) {
      print('❌ Erreur demanderRetrait: $e');
      throw Exception('Impossible de demander le retrait');
    }
  }

  // 2️⃣ Propriétaire consulte son historique de retraits
  Future<List<Retrait>> getHistoriqueRetraits() async {
    try {
      final response =
          await _apiService.get('${ApiConstants.retraits}/historique');

      if (response.data['retraits'] != null) {
        return (response.data['retraits'] as List)
            .map((json) => Retrait.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getHistoriqueRetraits: $e');
      throw Exception('Impossible de charger l\'historique');
    }
  }

  // 3️⃣ Admin : Lister les retraits en attente
  Future<List<Retrait>> getRetraitsEnAttente() async {
    try {
      final response =
          await _apiService.get('${ApiConstants.retraits}/en-attente');

      if (response.data['retraits'] != null) {
        return (response.data['retraits'] as List)
            .map((json) => Retrait.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getRetraitsEnAttente: $e');
      throw Exception('Impossible de charger les retraits');
    }
  }

  // 4️⃣ Admin : Valider un retrait
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

  // 5️⃣ Admin : Refuser un retrait
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
