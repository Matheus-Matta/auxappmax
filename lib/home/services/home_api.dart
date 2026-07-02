import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/home_dashboard.dart';

class HomeApi {
  const HomeApi({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<HomeDashboard> getDashboard({
    required String backendBaseUrl,
    required String token,
  }) async {
    final client = _client ?? http.Client();

    try {
      final response = await client.get(
        Uri.parse('${backendBaseUrl.trim()}/dashboard'),
        headers: _headers(token),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _throwIfError(response.statusCode, data);

      return HomeDashboard.fromJson(data['dashboard'] as Map<String, dynamic>);
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<String> runAction({
    required String backendBaseUrl,
    required String token,
    required String key,
  }) async {
    final client = _client ?? http.Client();

    try {
      final response = await client.post(
        Uri.parse('${backendBaseUrl.trim()}/executables/$key/run'),
        headers: _headers(token),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _throwIfError(response.statusCode, data);

      return data['message'] as String? ?? 'Executavel concluido';
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
      throw Exception(data['error'] ?? 'Falha ao processar dashboard.');
    }
  }
}
