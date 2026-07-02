class UserConfig {
  const UserConfig({
    required this.userId,
    required this.fdcUser,
    required this.fdcPass,
    this.id,
  });

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(
      id: json['id'] == null ? null : (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      fdcUser: json['fdcUser'] as String? ?? '',
      fdcPass: json['fdcPass'] as String? ?? '',
    );
  }

  final int? id;
  final int userId;
  final String fdcUser;
  final String fdcPass;

  Map<String, dynamic> toJson() {
    return {'fdcUser': fdcUser, 'fdcPass': fdcPass};
  }
}
