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
}
