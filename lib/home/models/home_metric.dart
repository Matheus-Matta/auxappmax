class HomeMetric {
  const HomeMetric({
    required this.label,
    required this.value,
    required this.meta,
  });

  factory HomeMetric.fromJson(Map<String, dynamic> json) {
    return HomeMetric(
      label: json['label'] as String,
      value: json['value'] as String,
      meta: json['meta'] as String,
    );
  }

  final String label;
  final String value;
  final String meta;
}
