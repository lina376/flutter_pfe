class UserModel {
  final String nom;
  final String prenom;
  final String email;
  final String dateNaissance;

  UserModel({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.dateNaissance,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      nom: (data['nom'] ?? '').toString(),
      prenom: (data['prenom'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      dateNaissance: (data['dateNaissance'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'dateNaissance': dateNaissance,
    };
  }

  UserModel copyWith({
    String? nom,
    String? prenom,
    String? email,
    String? dateNaissance,
  }) {
    return UserModel(
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      dateNaissance: dateNaissance ?? this.dateNaissance,
    );
  }
}
