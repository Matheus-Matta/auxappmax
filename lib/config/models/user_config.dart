class UserConfig {
  const UserConfig({
    required this.userId,
    required this.fdcUser,
    required this.fdcPass,
    required this.automationFramework,
    required this.browserMode,
    required this.browserEngine,
    required this.actionTimeoutMs,
    this.id,
  });

  factory UserConfig.empty({int userId = 0}) {
    return UserConfig(
      userId: userId,
      fdcUser: '',
      fdcPass: '',
      automationFramework: 'playwright',
      browserMode: 'visible',
      browserEngine: 'chromium',
      actionTimeoutMs: 30000,
    );
  }

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      fdcUser: json['fdcUser'] as String? ?? '',
      fdcPass: json['fdcPass'] as String? ?? '',
      automationFramework:
          json['automationFramework'] as String? ?? 'playwright',
      browserMode: json['browserMode'] as String? ?? 'visible',
      browserEngine: json['browserEngine'] as String? ?? 'chromium',
      actionTimeoutMs: (json['actionTimeoutMs'] as num?)?.toInt() ?? 30000,
    );
  }

  final int? id;
  final int userId;
  final String fdcUser;
  final String fdcPass;
  final String automationFramework;
  final String browserMode;
  final String browserEngine;
  final int actionTimeoutMs;

  bool get runInBackground => browserMode == 'background';

  Map<String, dynamic> toJson() {
    return {
      'fdcUser': fdcUser,
      'fdcPass': fdcPass,
      'automationFramework': automationFramework,
      'browserMode': browserMode,
      'browserEngine': browserEngine,
      'actionTimeoutMs': actionTimeoutMs,
    };
  }
}
