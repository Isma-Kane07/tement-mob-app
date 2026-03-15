import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/models/user.dart';
import 'package:tement_mobile/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Récupérer le profil de l'utilisateur connecté
  Future<User> getProfil() async {
    try {
      final response = await _apiService.get(ApiConstants.users);
      return User.fromJson(response.data);
    } catch (e) {
      print('❌ Erreur getProfil: $e');
      throw Exception('Impossible de charger le profil');
    }
  }

  // Mettre à jour le profil
  Future<User> updateProfil({
    String? nom,
    String? motDePasse,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (nom != null) data['nom'] = nom;
      if (motDePasse != null) data['mot_de_passe'] = motDePasse;
      if (photoUrl != null) data['photo_url'] = photoUrl;

      final response = await _apiService.put(
        ApiConstants.users,
        data: data,
      );

      return User.fromJson(response.data['user']);
    } catch (e) {
      print('❌ Erreur updateProfil: $e');
      throw Exception('Impossible de mettre à jour le profil');
    }
  }
}
