import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_config.dart';

class UserConfigApi {
  const UserConfigApi({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<UserConfig> getMyConfig({
    required String backendBaseUrl,
    required String token,
  }) {
    return _getConfig(
      endpoint: '${backendBaseUrl.trim()}/auth/me/config',
      token: token,
    );
  }

  Future<UserConfig> saveMyConfig({
    required String backendBaseUrl,
    required String token,
    required UserConfig config,
  }) {
    return _saveConfig(
      endpoint: '${backendBaseUrl.trim()}/auth/me/config',
      token: token,
      config: config,
    );
  }

  Future<UserConfig> getUserConfig({
    required String backendBaseUrl,
    required String token,
    required int userId,
  }) {
    return _getConfig(
      endpoint: '${backendBaseUrl.trim()}/auth/users/$userId/config',
      token: token,
    );
  }

  Future<UserConfig> saveUserConfig({
    required String backendBaseUrl,
    required String token,
    required UserConfig config,
  }) {
    return _saveConfig(
      endpoint: '${backendBaseUrl.trim()}/auth/users/${config.userId}/config',
      token: token,
      config: config,
    );
  }

  Future<UserConfig> _getConfig({
    required String endpoint,
    required String token,
  }) async {
    final client = _client ?? http.Client();

    try {
      final response = await client.get(
        Uri.parse(endpoint),
        headers: _headers(token),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _throwIfError(response.statusCode, data);

      return UserConfig.fromJson(data['config'] as Map<String, dynamic>);
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<UserConfig> _saveConfig({
    required String endpoint,
    required String token,
    required UserConfig config,
  }) async {
    final client = _client ?? http.Client();

    try {
      final response = await client.put(
        Uri.parse(endpoint),
        headers: _headers(token),
        body: jsonEncode(config.toJson()),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _throwIfError(response.statusCode, data);

      return UserConfig.fromJson(data['config'] as Map<String, dynamic>);
    } finally {
      if (_client == null) client.close();
    }
  }

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  void _throwIfError(int statusCode, Map<String, dynamic> data) {
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception(data['error'] ?? 'Falha ao processar configuracao.');
    }
  }
}
