class LocalAutomationResult {
  const LocalAutomationResult({required this.rawJson});

  factory LocalAutomationResult.fromJson(Map<String, dynamic> json) {
    return LocalAutomationResult(rawJson: json);
  }

  final Map<String, dynamic> rawJson;
}
