// lib/providers/admin_provider.dart
import 'package:flutter/material.dart';
import 'package:tement_mobile/services/api_service.dart';
import 'package:tement_mobile/config/constants.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _dashboard;
  List<Map<String, dynamic>> _paiementsEnAttente = [];
  List<Map<String, dynamic>> _retraitsEnAttente = [];
  List<Map<String, dynamic>> _utilisateurs = [];
  List<Map<String, dynamic>> _commissions = [];
  List<Map<String, dynamic>> _transactions = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get dashboard => _dashboard;
  List<Map<String, dynamic>> get paiementsEnAttente => _paiementsEnAttente;
  List<Map<String, dynamic>> get retraitsEnAttente => _retraitsEnAttente;
  List<Map<String, dynamic>> get utilisateurs => _utilisateurs;
  List<Map<String, dynamic>> get commissions => _commissions;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalCommissions {
    return _commissions.fold(0, (sum, c) => sum + (c['montant'] ?? 0));
  }

  // Dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/admin/dashboard');
      _dashboard = response.data;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur loadDashboard: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Paiements en attente
  Future<void> loadPaiementsEnAttente() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/paiements/en-attente');
      _paiementsEnAttente =
          List<Map<String, dynamic>>.from(response.data['paiements']);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur loadPaiementsEnAttente: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Valider un paiement
  Future<bool> validerPaiement(int paiementId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('/paiements/valider', data: {
        'paiement_id': paiementId,
      });
      await loadPaiementsEnAttente();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur validerPaiement: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Retraits en attente
  Future<void> loadRetraitsEnAttente() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/retraits/en-attente');
      _retraitsEnAttente =
          List<Map<String, dynamic>>.from(response.data['retraits']);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur loadRetraitsEnAttente: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Valider un retrait
  Future<bool> validerRetrait(
      int transactionId, String referenceVirement) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('/retraits/valider', data: {
        'transaction_id': transactionId,
        'reference_virement': referenceVirement,
      });
      await loadRetraitsEnAttente();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur validerRetrait: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refuser un retrait
  Future<bool> refuserRetrait(int transactionId, String raison) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('/retraits/refuser', data: {
        'transaction_id': transactionId,
        'raison': raison,
      });
      await loadRetraitsEnAttente();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur refuserRetrait: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Utilisateurs
  Future<void> loadUtilisateurs({String? role, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic> queryParams = {};
      if (role != null && role != 'all') queryParams['role'] = role;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get('/admin/utilisateurs',
          queryParams: queryParams);
      _utilisateurs =
          List<Map<String, dynamic>>.from(response.data['utilisateurs']);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur loadUtilisateurs: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Commissions
  Future<void> loadCommissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/admin/commissions');
      _commissions =
          List<Map<String, dynamic>>.from(response.data['commissions']);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur loadCommissions: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Transactions
  Future<void> loadTransactions(
      {String? type, String? startDate, String? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Map<String, dynamic> queryParams = {};
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response =
          await _apiService.get('/transactions', queryParams: queryParams);
      _transactions =
          List<Map<String, dynamic>>.from(response.data['transactions']);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ Erreur loadTransactions: $_error');
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
