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
    key: 'sync_base',
    title: 'Sincronizar Base',
    subtitle: 'Atualiza registros do ERP',
    badge: 'ROTINA',
    iconName: 'storage',
  ),
  HomeAction(
    key: 'report',
    title: 'Gerar Relatorio',
    subtitle: 'Exporta relatorio mensal PDF',
    badge: 'RELATORIO',
    iconName: 'description',
  ),
  HomeAction(
    key: 'upload',
    title: 'Enviar Arquivos',
    subtitle: 'Upload em lote para o servidor',
    badge: 'TRANSFERENCIA',
    iconName: 'upload',
  ),
  HomeAction(
    key: 'backup',
    title: 'Baixar Backup',
    subtitle: 'Snapshot dos ultimos 7 dias',
    badge: 'BACKUP',
    iconName: 'download',
  ),
  HomeAction(
    key: 'email',
    title: 'Disparo de E-mails',
    subtitle: 'Notifica clientes pendentes',
    badge: 'COMUNICACAO',
    iconName: 'mail',
  ),
  HomeAction(
    key: 'queue',
    title: 'Reprocessar Filas',
    subtitle: 'Executa jobs travados',
    badge: 'SISTEMA',
    iconName: 'sync',
  ),
  HomeAction(
    key: 'console',
    title: 'Console Remoto',
    subtitle: 'Acesso a scripts internos',
    badge: 'AVANCADO',
    iconName: 'terminal',
  ),
  HomeAction(
    key: 'folders',
    title: 'Sync de Pastas',
    subtitle: 'Espelhar diretorios de rede',
    badge: 'ARQUIVOS',
    iconName: 'folder',
  ),
];
