class User {
  final int id;
  final String nom;
  final String telephone;
  final String role;
  final String? photoUrl;
  final double walletBalance;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.role,
    this.photoUrl,
    required this.walletBalance,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      telephone: json['telephone'] ?? '',
      role: json['role'] ?? 'locataire',
      photoUrl: json['photo_url'],
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'role': role,
      'photo_url': photoUrl,
      'wallet_balance': walletBalance,
    };
  }

  bool get isLocataire => role == 'locataire';
  bool get isProprietaire => role == 'proprietaire';
  bool get isAdmin => role == 'admin';
}
