import 'package:flutter/material.dart';
import 'package:tement_mobile/models/user.dart';
import 'package:tement_mobile/services/auth_service.dart';
import 'package:tement_mobile/services/user_service.dart';
import 'package:tement_mobile/services/upload_service.dart';
import 'package:tement_mobile/services/storage_service.dart';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StorageService _storage = StorageService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  // Charger l'utilisateur depuis le stockage
  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _storage.getUser();
      print('📦 Utilisateur chargé: ${_user?.nom}');
    } catch (e) {
      print('❌ Erreur chargement user: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Connexion
  Future<bool> login(String telephone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📤 Tentative connexion: $telephone');
      _user = await _authService.login(telephone, password);
      print('✅ Connexion réussie pour ${_user?.nom}');

      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Erreur connexion: $e');

      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('not found') ||
          errorMessage.contains('non trouvé')) {
        _error = 'Numéro de téléphone incorrect';
      } else if (errorMessage.contains('password') ||
          errorMessage.contains('incorrect')) {
        _error = 'Mot de passe incorrect';
      } else if (errorMessage.contains('Connection refused')) {
        _error = 'Impossible de joindre le serveur';
      } else {
        _error = errorMessage;
      }

      return false;
    } finally {
      _isLoading = false;
      if (_error != null) {
        notifyListeners();
      }
    }
  }

  // Inscription
  Future<bool> signup({
    required String nom,
    required String telephone,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📤 Tentative d\'inscription: $telephone, $role');

      _user = await _authService.signup(
        nom: nom,
        telephone: telephone,
        motDePasse: password,
        role: role,
      );

      print('✅ Inscription réussie pour ${_user?.nom}');

      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Erreur inscription: $e');

      String errorMessage = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.contains('Téléphone déjà utilisé')) {
        _error = 'Ce numéro de téléphone est déjà utilisé';
      } else if (errorMessage.contains('validation failed')) {
        _error = 'Veuillez vérifier les informations saisies';
      } else if (errorMessage.contains('Connection refused')) {
        _error =
            'Impossible de joindre le serveur. Vérifiez que le backend est lancé.';
      } else {
        _error = errorMessage;
      }

      return false;
    } finally {
      _isLoading = false;
      if (_error != null) {
        notifyListeners();
      }
    }
  }

  // ✅ Mettre à jour le profil
  Future<bool> updateProfile({
    String? nom,
    String? motDePasse,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📤 Mise à jour du profil...');

      final updatedUser = await _userService.updateProfil(
        nom: nom,
        motDePasse: motDePasse,
        photoUrl: photoUrl,
      );

      // Mettre à jour l'utilisateur local
      _user = updatedUser;
      await _storage.saveUser(updatedUser);

      print('✅ Profil mis à jour avec succès');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Erreur mise à jour profil: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Mettre à jour la photo de profil (avec upload)
  Future<bool> updateProfilePhoto(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📤 Upload de la photo de profil...');
      final uploadService = UploadService();
      final photoUrl = await uploadService.uploadProfilePhoto(File(imagePath));

      print('✅ Photo uploadée: $photoUrl');

      // Mettre à jour le profil avec la nouvelle URL
      return await updateProfile(photoUrl: photoUrl);
    } catch (e) {
      print('❌ Erreur upload photo: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      print('👋 Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le wallet
  void updateWalletBalance(double newBalance) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        nom: _user!.nom,
        telephone: _user!.telephone,
        role: _user!.role,
        photoUrl: _user!.photoUrl,
        walletBalance: newBalance,
      );
      _storage.saveUser(_user!);
      notifyListeners();
    }
  }

  // Rafraîchir le profil depuis le serveur
  Future<void> refreshProfile() async {
    try {
      final freshUser = await _userService.getProfil();
      _user = freshUser;
      await _storage.saveUser(freshUser);
      notifyListeners();
      print('✅ Profil rafraîchi');
    } catch (e) {
      print('❌ Erreur rafraîchissement profil: $e');
    }
  }
}
