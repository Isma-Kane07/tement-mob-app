import 'package:flutter/material.dart';
import 'package:tement_mobile/models/reservation.dart';
import 'package:tement_mobile/services/reservation_service.dart';
import 'package:tement_mobile/providers/auth_provider.dart';

class ReservationProvider extends ChangeNotifier {
  final ReservationService _reservationService = ReservationService();

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Charger les réservations selon le rôle de l'utilisateur
  Future<void> loadReservations(AuthProvider authProvider) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = authProvider.user;

      if (user == null) {
        _reservations = [];
        return;
      }

      if (user.isLocataire) {
        // Locataire : ses propres réservations
        _reservations = await _reservationService.getMesReservations();
        print('✅ ${_reservations.length} réservations (locataire)');
      } else if (user.isProprietaire) {
        // Propriétaire : réservations de ses logements
        _reservations = await _reservationService.getReservationsProprietaire();
        print('✅ ${_reservations.length} réservations (propriétaire)');
      } else {
        _reservations = [];
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur chargement réservations: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pour compatibilité (garder l'ancienne méthode)
  Future<void> loadMesReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _reservationService.getMesReservations();
      print('✅ ${_reservations.length} réservations chargées');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur chargement réservations: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pour compatibilité (garder l'ancienne méthode)
  Future<void> loadReservationsProprietaire() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _reservationService.getReservationsProprietaire();
      print('✅ ${_reservations.length} réservations propriétaire');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer une réservation
  Future<bool> creerReservation({
    required int logementId,
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nouvelleReservation = await _reservationService.creerReservation(
        logementId: logementId,
        dateDebut: _formatDate(dateDebut),
        dateFin: _formatDate(dateFin),
      );

      _reservations.insert(0, nouvelleReservation);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Confirmer une réservation (propriétaire)
  Future<bool> confirmerReservation(int reservationId) async {
    try {
      final updated =
          await _reservationService.confirmerReservation(reservationId);
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  // Annuler une réservation
  Future<bool> annulerReservation(int reservationId) async {
    try {
      final updated =
          await _reservationService.annulerReservation(reservationId);
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
