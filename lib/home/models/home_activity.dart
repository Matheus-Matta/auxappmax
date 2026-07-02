class HomeActivity {
  const HomeActivity({
    required this.time,
    required this.title,
    required this.status,
  });

  factory HomeActivity.fromJson(Map<String, dynamic> json) {
    return HomeActivity(
      time: json['time'] as String? ?? '--:--',
      title: json['title'] as String? ?? 'Evento operacional',
      status: json['status'] as String? ?? 'Info',
    );
  }

  final String time;
  final String title;
  final String status;
}
