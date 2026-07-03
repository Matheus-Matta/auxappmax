import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/fdc_login_command.dart';
import '../models/local_automation_result.dart';

class LocalWebAutomation {
  const LocalWebAutomation();

  Future<LocalAutomationResult> scrape(Map<String, dynamic> payload) async {
    final data = await _run('scrape', payload);
    return LocalAutomationResult.fromJson(data);
  }

  Future<LocalAutomationResult> loginFdc(FdcLoginCommand command) async {
    final data = await _run('fdc-login', command.toJson());
    return LocalAutomationResult.fromJson(data);
  }

  Future<Map<String, dynamic>> runRawScrape(Map<String, dynamic> payload) {
    return _run('scrape', payload);
  }

  Future<Map<String, dynamic>> _run(
    String command,
    Map<String, dynamic> payload,
  ) async {
    final script = _findAutomationScript();
    final node = _findNodeExecutable();
    final encodedPayload = base64Encode(utf8.encode(jsonEncode(payload)));
    final result = await Process.run(node, [
      script.path,
      command,
      encodedPayload,
    ]);

    final stdout = result.stdout.toString().trim();
    final stderr = result.stderr.toString().trim();
    final data = stdout.isEmpty
        ? <String, dynamic>{'ok': false, 'error': stderr}
        : jsonDecode(stdout) as Map<String, dynamic>;

    if (result.exitCode != 0 || data['ok'] != true) {
      final message = data['error'] ?? stderr;
      throw Exception(
        message.toString().isEmpty
            ? 'Falha ao executar automacao local.'
            : message,
      );
    }

    return data;
  }

  File _findAutomationScript() {
    const relativePath = ['local_automation', 'cli.js'];
    final candidates = <Directory>[
      Directory.current,
      File(Platform.resolvedExecutable).parent,
    ];

    for (final start in candidates) {
      Directory? current = start.absolute;

      while (current != null) {
        final file = File(_join([current.path, ...relativePath]));
        if (file.existsSync()) return file;

        final parent = current.parent;
        current = parent.path == current.path ? null : parent;
      }
    }

    throw Exception(
      'Nao encontrei local_automation/cli.js para automacao local.',
    );
  }

  String _findNodeExecutable() {
    const windowsNode = r'C:\Program Files\nodejs\node.exe';
    if (Platform.isWindows && File(windowsNode).existsSync()) {
      return windowsNode;
    }

    return Platform.isWindows ? 'node.exe' : 'node';
  }

  String _join(List<String> parts) {
    return parts.join(Platform.pathSeparator);
  }
}
