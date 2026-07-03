import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_payload.dart';
import '../models/user_record.dart';

class UsersApi {
  const UsersApi();

  static const _usersKey = 'appmax.local_users.v1';

  Future<List<UserRecord>> listUsers({required String search}) async {
    final users = await _loadUsers();
    final query = search.trim().toLowerCase();

    if (query.isEmpty) return users;

    return users
        .where(
          (user) =>
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.role.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<UserRecord> createUser({required UserPayload payload}) async {
    final users = await _loadUsers();
    final nextId = users.isEmpty
        ? 1
        : users.map((user) => user.id).reduce((a, b) => a > b ? a : b) + 1;
    final user = _fromPayload(nextId, payload);

    users.add(user);
    await _saveUsers(users);

    return user;
  }

  Future<UserRecord> updateUser({
    required int id,
    required UserPayload payload,
  }) async {
    final users = await _loadUsers();
    final index = users.indexWhere((user) => user.id == id);

    if (index == -1) {
      throw Exception('Usuario nao encontrado.');
    }

    final user = _fromPayload(id, payload);
    users[index] = user;
    await _saveUsers(users);

    return user;
  }

  Future<void> deleteUser({required int id}) async {
    final users = await _loadUsers()
      ..removeWhere((user) => user.id == id);

    await _saveUsers(users);
  }

  Future<List<UserRecord>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);

    if (raw == null || raw.trim().isEmpty) return const [];

    return (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(UserRecord.fromJson)
        .toList();
  }

  Future<void> _saveUsers(List<UserRecord> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users.map(_toJson).toList()));
  }

  UserRecord _fromPayload(int id, UserPayload payload) {
    final permissionLevel = switch (payload.role) {
      'admin' => 100,
      'operator' => 50,
      _ => 10,
    };

    return UserRecord(
      id: id,
      name: payload.name,
      email: payload.email,
      role: payload.role,
      permissionLevel: permissionLevel,
      active: payload.active,
    );
  }

  Map<String, dynamic> _toJson(UserRecord user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'permissionLevel': user.permissionLevel,
      'active': user.active,
    };
  }
}
