class UserPayload {
  const UserPayload({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.active,
  });

  final String name;
  final String email;
  final String password;
  final String role;
  final bool active;

  Map<String, dynamic> toJson({required bool editing}) {
    return {
      'name': name,
      'email': email,
      if (!editing || password.isNotEmpty) 'password': password,
      if (editing && password.isEmpty) 'password': '',
      'role': role,
      'active': active,
    };
  }
}
