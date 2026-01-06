class UserModel {
  int id;
  String name;
  String email;
  String? profileImageBase64;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageBase64,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageBase64: json['profileImageBase64'], // may be null for API users
    );
  }
}
