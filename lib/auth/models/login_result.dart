import 'auth_user.dart';

class LoginResult {
  const LoginResult({required this.token, required this.user});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    if (json['ok'] != true) {
      throw Exception(json['error'] ?? 'Login invalido.');
    }

    return LoginResult(
      token: json['token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String token;
  final AuthUser user;
}
