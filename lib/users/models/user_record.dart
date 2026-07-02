class UserRecord {
  const UserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissionLevel,
    required this.active,
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) {
    return UserRecord(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      permissionLevel: (json['permissionLevel'] as num).toInt(),
      active: json['active'] == true,
    );
  }

  final int id;
  final String name;
  final String email;
  final String role;
  final int permissionLevel;
  final bool active;
}
