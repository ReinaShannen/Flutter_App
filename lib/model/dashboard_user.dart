class DashboardUser {
  final String id; 
  final String name;
  final String email;
  final bool isRegistered;
  final String? profileImageBase64;

  DashboardUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isRegistered,
    this.profileImageBase64,
  });

  DashboardUser copyWith({
    String? id,
    String? name,
    String? email,
    bool? isRegistered,
    String? profileImageBase64,
  }) {
    return DashboardUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isRegistered: isRegistered ?? this.isRegistered,
      profileImageBase64:
          profileImageBase64 ?? this.profileImageBase64,
    );
  }
}