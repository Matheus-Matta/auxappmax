import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_config.dart';

class UserConfigApi {
  const UserConfigApi({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _configKey = 'appmax.user_config.v1';

  final FlutterSecureStorage _storage;

  Future<UserConfig> getMyConfig() async {
    final raw = await _storage.read(key: _configKey);

    if (raw == null || raw.trim().isEmpty) {
      return UserConfig.empty();
    }

    return UserConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<UserConfig> saveMyConfig({required UserConfig config}) async {
    await _storage.write(key: _configKey, value: jsonEncode(config.toJson()));
    return config;
  }

  Future<UserConfig> getUserConfig({required int userId}) {
    return getMyConfig();
  }

  Future<UserConfig> saveUserConfig({required UserConfig config}) {
    return saveMyConfig(config: config);
  }
}
