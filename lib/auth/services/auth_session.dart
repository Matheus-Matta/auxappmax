import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

class AuthSession extends ChangeNotifier {
  static const _userKey = 'auth.user';

  bool _loading = true;
  AuthUser? _user;

  bool get loading => _loading;
  bool get isAuthenticated => _user != null;
  AuthUser? get user => _user;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    _user = userJson == null
        ? null
        : AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    _loading = false;
    notifyListeners();
  }

  Future<void> signIn({required AuthUser user}) async {
    final prefs = await SharedPreferences.getInstance();

    _user = user;

    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    _user = null;

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
