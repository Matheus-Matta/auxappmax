import '../models/execution_report.dart';
import '../services/execution_log_service.dart';

abstract class ExecutionReportsView {
  void setReportsLoading(bool value);
  void showReportsLoaded(ExecutionReportPage page);
  void showReportsError(Object error);
}

class ExecutionReportsPresenter {
  ExecutionReportsPresenter({ExecutionLogService? logService})
    : _logService = logService ?? const ExecutionLogService();

  final ExecutionLogService _logService;
  ExecutionReportsView? _view;

  void attach(ExecutionReportsView view) {
    _view = view;
  }

  void detach() {
    _view = null;
  }

  Future<void> loadReports({required int limit, required int offset}) async {
    _view?.setReportsLoading(true);

    try {
      final page = await _logService.list(limit: limit, offset: offset);
      _view?.showReportsLoaded(page);
    } catch (error) {
      _view?.showReportsError(error);
    } finally {
      _view?.setReportsLoading(false);
    }
  }
}
