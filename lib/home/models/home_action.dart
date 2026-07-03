import 'package:flutter/material.dart';

class HomeAction {
  const HomeAction({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.iconName,
    this.enabled = true,
  });

  factory HomeAction.fromJson(Map<String, dynamic> json) {
    return HomeAction(
      key: json['key'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      badge: json['badge'] as String,
      iconName: json['icon'] as String? ?? 'play',
      enabled: json['enabled'] != false,
    );
  }

  final String key;
  final String title;
  final String subtitle;
  final String badge;
  final String iconName;
  final bool enabled;

  IconData get icon {
    return switch (iconName) {
      'storage' => Icons.storage_outlined,
      'description' => Icons.description_outlined,
      'upload' => Icons.upload_outlined,
      'download' => Icons.download_outlined,
      'mail' => Icons.mail_outline,
      'sync' => Icons.sync_outlined,
      'terminal' => Icons.terminal_outlined,
      'folder' => Icons.folder_outlined,
      'key' => Icons.key_outlined,
      _ => Icons.play_arrow_outlined,
    };
  }
}

const fallbackHomeActions = [
  HomeAction(
    key: 'test_login_scraping',
    title: 'Fazer login teste',
    subtitle: 'Abre o FDC e testa login com auto clique',
    badge: 'FDC',
    iconName: 'key',
  ),
];
