import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/scrape_request.dart';
import '../models/scrape_result.dart';

class ScraperApi {
  const ScraperApi({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<ScrapeResult> runScrape({
    required String backendBaseUrl,
    required String token,
    required ScrapeRequest request,
  }) async {
    final client = _client ?? http.Client();

    try {
      final endpoint = Uri.parse('${backendBaseUrl.trim()}/scrape');
      final response = await client.post(
        endpoint,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ScrapeResult.fromJson(data);
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
