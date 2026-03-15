class ApiConstants {
  // ✅ URL DE PRODUCTION (Railway)
  static const String baseUrl = 'https://tement-back.up.railway.app/api';

  // URLs de développement (gardées en commentaire pour référence)
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // Émulateur Android
  // static const String baseUrl = 'http://ABBA-COMPUTER:5000/api'; // Réseau local

  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';

  // Logements
  static const String logements = '/logements';

  // Réservations
  static const String reservations = '/reservations';

  // Paiements
  static const String paiements = '/paiements';

  // Retraits
  static const String retraits = '/retraits';

  // Wallet
  static const String wallet = '/wallet/historique';

  // Users
  static const String users = '/users/me';

  // Optionnel : Health check pour debug
  static const String health = '/health';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String user = 'user_data';
}

class AppStrings {
  static const String appName = 'Tement';
  static const String welcome = 'Bienvenue sur Tement';
  static const String login = 'Se connecter';
  static const String signup = 'S\'inscrire';
  static const String logout = 'Déconnexion';
  static const String phone = 'Téléphone';
  static const String password = 'Mot de passe';
  static const String name = 'Nom';
  static const String role = 'Rôle';
  static const String locataire = 'Locataire';
  static const String proprietaire = 'Propriétaire';
}

class ErrorMessages {
  static const String networkError = 'Problème de connexion internet';
  static const String serverError = 'Erreur serveur, veuillez réessayer';
  static const String timeoutError = 'Délai d\'attente dépassé';
  static const String unauthorized =
      'Session expirée, veuillez vous reconnecter';
}
