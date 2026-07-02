import 'home_action.dart';
import 'home_activity.dart';
import 'home_metric.dart';

class HomeDashboard {
  const HomeDashboard({
    required this.actions,
    required this.activities,
    required this.metrics,
  });

  factory HomeDashboard.fromJson(Map<String, dynamic> json) {
    return HomeDashboard(
      actions: (json['actions'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HomeAction.fromJson)
          .toList(),
      activities: (json['activities'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HomeActivity.fromJson)
          .toList(),
      metrics: (json['metrics'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(HomeMetric.fromJson)
          .toList(),
    );
  }

  final List<HomeAction> actions;
  final List<HomeActivity> activities;
  final List<HomeMetric> metrics;
}
