import '../models/home_action.dart';
import '../models/home_activity.dart';
import '../models/home_dashboard.dart';
import '../models/home_metric.dart';
import '../services/executable_action_service.dart';
import '../services/execution_log_service.dart';

abstract class HomeView {
  void showDashboardLoaded(HomeDashboard dashboard);
  void showDashboardError(Object error);
  void showActionStarted(HomeAction action);
  void showActionSuccess(HomeAction action, String message);
  void showActionError(HomeAction action, Object error);
}

class HomePresenter {
  HomePresenter({
    ExecutableActionService? actionService,
    ExecutionLogService? logService,
  }) : _actionService = actionService ?? const ExecutableActionService(),
       _logService = logService ?? const ExecutionLogService();

  final ExecutableActionService _actionService;
  final ExecutionLogService _logService;
  HomeView? _view;

  void attach(HomeView view) {
    _view = view;
  }

  void detach() {
    _view = null;
  }

  Future<void> loadDashboard() async {
    try {
      final reports = await _logService.list(limit: 8);
      final successes = reports.runs.where((run) => run.success).length;
      final successRate = reports.total == 0
          ? 100.0
          : (successes / reports.runs.length) * 100;
      final activities = reports.runs
          .map(
            (run) => HomeActivity(
              time: run.time,
              title: run.title,
              status: run.status,
            ),
          )
          .toList();

      _view?.showDashboardLoaded(
        HomeDashboard(
          actions: fallbackHomeActions,
          activities: activities,
          metrics: [
            HomeMetric(label: 'Jobs', value: '${reports.total}', meta: 'local'),
            HomeMetric(
              label: 'Sucesso',
              value: '${successRate.toStringAsFixed(1).replaceAll('.', ',')}%',
              meta: '$successes/${reports.runs.length}',
            ),
            const HomeMetric(label: 'Executaveis', value: '1', meta: 'local'),
            const HomeMetric(
              label: 'Usuarios',
              value: 'local',
              meta: 'sem API',
            ),
          ],
        ),
      );
    } catch (error) {
      _view?.showDashboardError(error);
    }
  }

  Future<void> execute({required HomeAction action}) async {
    _view?.showActionStarted(action);

    try {
      final message = await _actionService.execute(action: action);

      _view?.showActionSuccess(action, message);
    } catch (error) {
      _view?.showActionError(action, error);
    }
  }
}
