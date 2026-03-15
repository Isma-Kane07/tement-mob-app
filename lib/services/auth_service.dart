import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/models/user.dart';
import 'package:tement_mobile/services/api_service.dart';
import 'package:tement_mobile/services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  // Connexion
  Future<User> login(String telephone, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'telephone': telephone,
          'mot_de_passe': password,
        },
      );

      final data = response.data;

      // Sauvegarder le token
      await _storage.saveToken(data['token']);

      // Créer et sauvegarder l'utilisateur
      final user = User.fromJson(data['user']);
      await _storage.saveUser(user);

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Inscription
  Future<User> signup({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String role,
    String? photoUrl,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.signup,
        data: {
          'nom': nom,
          'telephone': telephone,
          'mot_de_passe': motDePasse,
          'role': role,
          'photo_url': photoUrl,
        },
      );

      final data = response.data;

      // Sauvegarder le token
      await _storage.saveToken(data['token']);

      // Créer et sauvegarder l'utilisateur
      final user = User.fromJson(data['user']);
      await _storage.saveUser(user);

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _storage.clearAll();
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  // Récupérer l'utilisateur connecté
  Future<User?> getCurrentUser() async {
    return await _storage.getUser();
  }
}
