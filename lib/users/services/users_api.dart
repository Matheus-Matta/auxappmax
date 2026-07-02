import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_payload.dart';
import '../models/user_record.dart';

class UsersApi {
  const UsersApi({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<List<UserRecord>> listUsers({
    required String backendBaseUrl,
    required String token,
    required String search,
  }) async {
    final client = _client ?? http.Client();

    try {
      final endpoint = Uri.parse(
        '${backendBaseUrl.trim()}/auth/users',
      ).replace(queryParameters: search.isEmpty ? null : {'search': search});
      final response = await client.get(endpoint, headers: _headers(token));
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _throwIfError(response.statusCode, data);

      return (data['users'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(UserRecord.fromJson)
          .toList();
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<UserRecord> createUser({
    required String backendBaseUrl,
    required String token,
    required UserPayload payload,
  }) {
    return _saveUser(
      method: 'POST',
      endpoint: '${backendBaseUrl.trim()}/auth/users',
      token: token,
      payload: payload,
      editing: false,
    );
  }

  Future<UserRecord> updateUser({
    required String backendBaseUrl,
    required String token,
    required int id,
    required UserPayload payload,
  }) {
    return _saveUser(
      method: 'PATCH',
      endpoint: '${backendBaseUrl.trim()}/auth/users/$id',
      token: token,
      payload: payload,
      editing: true,
    );
  }

  Future<void> deleteUser({
    required String backendBaseUrl,
    required String token,
    required int id,
  }) async {
    final client = _client ?? http.Client();

    try {
      final response = await client.delete(
        Uri.parse('${backendBaseUrl.trim()}/auth/users/$id'),
        headers: _headers(token),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _throwIfError(response.statusCode, data);
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<UserRecord> _saveUser({
    required String method,
    required String endpoint,
    required String token,
    required UserPayload payload,
    required bool editing,
  }) async {
    final client = _client ?? http.Client();

    try {
      final request = http.Request(method, Uri.parse(endpoint))
        ..headers.addAll(_headers(token))
        ..body = jsonEncode(payload.toJson(editing: editing));
      final streamed = await client.send(request);
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      _throwIfError(response.statusCode, data);

      return UserRecord.fromJson(data['user'] as Map<String, dynamic>);
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
      throw Exception(data['error'] ?? 'Falha ao processar usuario.');
    }
  }
}
