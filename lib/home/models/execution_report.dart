import 'dart:convert';

class ExecutionReportPage {
  const ExecutionReportPage({
    required this.runs,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ExecutionReportPage.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return ExecutionReportPage(
      runs: (json['runs'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(ExecutionReport.fromJson)
          .toList(),
      limit: (pagination['limit'] as num?)?.toInt() ?? 20,
      offset: (pagination['offset'] as num?)?.toInt() ?? 0,
      total: (pagination['total'] as num?)?.toInt() ?? 0,
    );
  }

  final List<ExecutionReport> runs;
  final int limit;
  final int offset;
  final int total;
}

class ExecutionReport {
  const ExecutionReport({
    required this.id,
    required this.key,
    required this.title,
    required this.success,
    required this.message,
    required this.result,
    required this.time,
    required this.createdAt,
  });

  factory ExecutionReport.fromJson(Map<String, dynamic> json) {
    return ExecutionReport(
      id: (json['id'] as num).toInt(),
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? 'Execucao',
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      result: json['result'] as Map<String, dynamic>? ?? {},
      time: json['time'] as String? ?? '--:--',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final int id;
  final String key;
  final String title;
  final bool success;
  final String message;
  final Map<String, dynamic> result;
  final String time;
  final String createdAt;

  String get status => success ? 'Sucesso' : 'Erro';

  String get resultPreview {
    if (result.isEmpty) return '-';

    return const JsonEncoder.withIndent('  ').convert(result);
  }
}
