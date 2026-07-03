class FdcLoginCommand {
  const FdcLoginCommand({
    required this.fdcUser,
    required this.fdcPass,
    required this.headless,
    required this.timeoutMs,
    this.closeDelayMs = 0,
  });

  final String fdcUser;
  final String fdcPass;
  final bool headless;
  final int closeDelayMs;
  final int timeoutMs;

  Map<String, dynamic> toJson() {
    return {
      'fdcUser': fdcUser,
      'fdcPass': fdcPass,
      'headless': headless,
      'closeDelayMs': closeDelayMs,
      'timeoutMs': timeoutMs,
    };
  }
}
