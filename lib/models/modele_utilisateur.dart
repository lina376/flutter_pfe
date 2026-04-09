class UserModel {
  final String nom;
  final String prenom;
  final String email;
  final String dateNaissance;
  final String photoUrl;

  UserModel({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.dateNaissance,
    required this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      nom: (data['nom'] ?? '').toString(),
      prenom: (data['prenom'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      dateNaissance: (data['dateNaissance'] ?? '').toString(),
      photoUrl: (data['photoUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'dateNaissance': dateNaissance,
      'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? nom,
    String? prenom,
    String? email,
    String? dateNaissance,
    String? photoUrl,
  }) {
    return UserModel(
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
