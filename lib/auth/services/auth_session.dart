import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

class AuthSession extends ChangeNotifier {
  static const _backendKey = 'auth.backend';
  static const _tokenKey = 'auth.token';
  static const _userKey = 'auth.user';

  bool _loading = true;
  String _backendBaseUrl = 'http://localhost:3333';
  String? _token;
  AuthUser? _user;

  bool get loading => _loading;
  bool get isAuthenticated => _token != null && _user != null;
  String get backendBaseUrl => _backendBaseUrl;
  String? get token => _token;
  AuthUser? get user => _user;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    _backendBaseUrl = prefs.getString(_backendKey) ?? _backendBaseUrl;
    _token = prefs.getString(_tokenKey);
    _user = userJson == null
        ? null
        : AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    _loading = false;
    notifyListeners();
  }

  Future<void> signIn({
    required String backendBaseUrl,
    required String token,
    required AuthUser user,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _backendBaseUrl = backendBaseUrl.trim();
    _token = token;
    _user = user;

    await prefs.setString(_backendKey, _backendBaseUrl);
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    _token = null;
    _user = null;

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthSession> {
  const AuthScope({
    required AuthSession session,
    required super.child,
    super.key,
  }) : super(notifier: session);

  static AuthSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();

    assert(scope != null, 'AuthScope nao encontrado.');
    return scope!.notifier!;
  }
}
