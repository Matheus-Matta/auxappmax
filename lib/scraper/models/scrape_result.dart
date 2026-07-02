import 'dart:convert';

class ScrapeResult {
  ScrapeResult({required this.ok, required this.rawJson});

  factory ScrapeResult.fromJson(Map<String, dynamic> json) {
    return ScrapeResult(
      ok: json['ok'] == true,
      rawJson: const JsonEncoder.withIndent('  ').convert(json),
    );
  }

  final bool ok;
  final String rawJson;

  String get status => ok ? 'Concluido.' : 'Falhou.';
}
