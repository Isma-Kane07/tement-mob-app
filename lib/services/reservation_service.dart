import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/models/reservation.dart';
import 'package:tement_mobile/services/api_service.dart';

class ReservationService {
  final ApiService _apiService = ApiService();

  // Créer une réservation
  // Créer une réservation
  Future<Reservation> creerReservation({
    required int logementId,
    required String dateDebut,
    required String dateFin,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.reservations,
        data: {
          'logement_id': logementId,
          'date_debut': dateDebut,
          'date_fin': dateFin,
        },
      );

      return Reservation.fromJson(response.data['reservation']);
    } catch (e) {
      print('❌ Erreur creerReservation: $e');
      throw Exception('Impossible de créer la réservation');
    }
  }

  // Récupérer les réservations du locataire connecté
  Future<List<Reservation>> getMesReservations() async {
    try {
      final response =
          await _apiService.get('${ApiConstants.reservations}/locataire');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Reservation.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getMesReservations: $e');
      throw Exception('Impossible de charger vos réservations');
    }
  }

  // Récupérer les réservations des logements du propriétaire
  Future<List<Reservation>> getReservationsProprietaire() async {
    try {
      final response =
          await _apiService.get('${ApiConstants.reservations}/proprietaire');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Reservation.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getReservationsProprietaire: $e');
      throw Exception('Impossible de charger les réservations');
    }
  }

  // Confirmer une réservation (propriétaire)
  Future<Reservation> confirmerReservation(int reservationId) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.reservations}/$reservationId/confirmer',
      );

      return Reservation.fromJson(response.data['reservation']);
    } catch (e) {
      print('❌ Erreur confirmerReservation: $e');
      throw Exception('Impossible de confirmer la réservation');
    }
  }

  // Annuler une réservation
  Future<Reservation> annulerReservation(int reservationId) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.reservations}/$reservationId/annuler',
      );

      return Reservation.fromJson(response.data['reservation']);
    } catch (e) {
      print('❌ Erreur annulerReservation: $e');
      throw Exception('Impossible d\'annuler la réservation');
    }
  }
}
