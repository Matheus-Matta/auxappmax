import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/login_request.dart';
import '../models/login_result.dart';

class AuthApi {
  const AuthApi({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<LoginResult> login({
    required String backendBaseUrl,
    required LoginRequest request,
  }) async {
    final client = _client ?? http.Client();

    try {
      final endpoint = Uri.parse('${backendBaseUrl.trim()}/auth/login');
      final response = await client.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data['error'] ?? 'Nao foi possivel entrar.');
      }

      return LoginResult.fromJson(data);
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
