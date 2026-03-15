import 'package:flutter/material.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/services/logement_service.dart';

class LogementProvider extends ChangeNotifier {
  final LogementService _logementService = LogementService();

  List<Logement> _logements = [];
  List<Logement> _mesLogements = []; // Pour le propriétaire
  bool _isLoading = false;
  String? _error;

  List<Logement> get logements => _logements;
  List<Logement> get mesLogements => _mesLogements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ MODIFIÉ : Charger tous les logements avec recherche
  Future<void> loadLogements({
    String? search,
    String? type,
    double? minPrix,
    double? maxPrix,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _logements = await _logementService.getLogements(
        search: search,
        type: type,
        minPrix: minPrix,
        maxPrix: maxPrix,
      );
      print('✅ ${_logements.length} logements chargés');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur chargement logements: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ NOUVEAU : Charger les logements du propriétaire connecté
  Future<void> loadMesLogements(int proprietaireId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mesLogements = await _logementService.getLogements(
        proprietaireId: proprietaireId,
      );
      print('✅ ${_mesLogements.length} logements chargés pour le propriétaire');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur chargement mes logements: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ NOUVEAU : Désactiver/Activer un logement
  Future<bool> toggleDisponibilite(int logementId, bool disponible) async {
    try {
      final updated =
          await _logementService.desactiverLogement(logementId, disponible);

      // Mettre à jour dans les deux listes
      final index = _logements.indexWhere((l) => l.id == logementId);
      if (index != -1) {
        _logements[index] = updated;
      }

      final indexMes = _mesLogements.indexWhere((l) => l.id == logementId);
      if (indexMes != -1) {
        _mesLogements[indexMes] = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  // Rafraîchir la liste
  Future<void> refreshLogements() async {
    await loadLogements();
  }

  // Ajouter un logement
  Future<bool> addLogement({
    required String type,
    required String adresse,
    required String description,
    required double prixNuit,
    List<String> photos = const [],
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nouveauLogement = await _logementService.creerLogement(
        type: type,
        adresse: adresse,
        description: description,
        prixNuit: prixNuit,
        photos: photos,
      );

      _logements.insert(0, nouveauLogement);
      _mesLogements.insert(0, nouveauLogement);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer un logement par ID
  Logement? getLogementById(int id) {
    try {
      return _logements.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour un logement
  Future<bool> updateLogement({
    required int id,
    String? type,
    String? adresse,
    String? description,
    double? prixNuit,
    List<String>? photos,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _logementService.modifierLogement(
        id: id,
        type: type,
        adresse: adresse,
        description: description,
        prixNuit: prixNuit,
        photos: photos,
      );

      final index = _logements.indexWhere((l) => l.id == id);
      if (index != -1) {
        _logements[index] = updated;
      }

      final indexMes = _mesLogements.indexWhere((l) => l.id == id);
      if (indexMes != -1) {
        _mesLogements[indexMes] = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer un logement
  Future<bool> deleteLogement(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _logementService.supprimerLogement(id);
      _logements.removeWhere((l) => l.id == id);
      _mesLogements.removeWhere((l) => l.id == id);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
