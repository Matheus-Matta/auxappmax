import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/execution_report.dart';

class ExecutionLogService {
  const ExecutionLogService();

  Future<void> record({
    required String key,
    required String title,
    required bool success,
    required String message,
    Map<String, dynamic> result = const {},
  }) async {
    final file = await _logFile();
    final now = DateTime.now();
    final entry = {
      'id': now.microsecondsSinceEpoch,
      'key': key,
      'title': title,
      'success': success,
      'message': message,
      'result': result,
      'time': _formatTime(now),
      'createdAt': now.toIso8601String(),
    };

    await file.writeAsString('${jsonEncode(entry)}\n', mode: FileMode.append);
  }

  Future<ExecutionReportPage> list({int limit = 20, int offset = 0}) async {
    final file = await _logFile();

    if (!await file.exists()) {
      return ExecutionReportPage(
        runs: const [],
        limit: limit,
        offset: offset,
        total: 0,
      );
    }

    final lines = await file.readAsLines();
    final reports = lines.reversed
        .where((line) => line.trim().isNotEmpty)
        .map((line) => jsonDecode(line) as Map<String, dynamic>)
        .map(ExecutionReport.fromJson)
        .toList();
    final page = reports.skip(offset).take(limit).toList();

    return ExecutionReportPage(
      runs: page,
      limit: limit,
      offset: offset,
      total: reports.length,
    );
  }

  Future<File> _logFile() async {
    final baseDir = await getApplicationSupportDirectory();
    final logDir = Directory('${baseDir.path}${Platform.pathSeparator}.logs');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    return File('${logDir.path}${Platform.pathSeparator}executions.log');
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
