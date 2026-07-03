class ScrapeRequest {
  const ScrapeRequest({
    required this.url,
    required this.clickSelector,
    required this.extractSelector,
    required this.waitForSelector,
    required this.headless,
    required this.timeoutMs,
  });

  final String url;
  final String clickSelector;
  final String extractSelector;
  final String waitForSelector;
  final bool headless;
  final int timeoutMs;

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'clickSelector': clickSelector,
      'extractSelector': extractSelector,
      'waitForSelector': waitForSelector,
      'headless': headless,
      'timeoutMs': timeoutMs,
    };
  }
}
