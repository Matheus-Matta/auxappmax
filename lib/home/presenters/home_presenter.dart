import '../models/home_action.dart';
import '../models/home_dashboard.dart';
import '../services/home_api.dart';

abstract class HomeView {
  void showDashboardLoaded(HomeDashboard dashboard);
  void showDashboardError(Object error);
  void showActionStarted(HomeAction action);
  void showActionSuccess(HomeAction action, String message);
  void showActionError(HomeAction action, Object error);
}

class HomePresenter {
  HomePresenter({required HomeApi homeApi}) : _homeApi = homeApi;

  final HomeApi _homeApi;
  HomeView? _view;

  void attach(HomeView view) {
    _view = view;
  }

  void detach() {
    _view = null;
  }

  Future<void> loadDashboard({
    required String backendBaseUrl,
    required String token,
  }) async {
    try {
      final dashboard = await _homeApi.getDashboard(
        backendBaseUrl: backendBaseUrl,
        token: token,
      );
      _view?.showDashboardLoaded(dashboard);
    } catch (error) {
      _view?.showDashboardError(error);
    }
  }

  Future<void> execute({
    required HomeAction action,
    required String backendBaseUrl,
    required String token,
  }) async {
    _view?.showActionStarted(action);

    try {
      final message = await _homeApi.runAction(
        backendBaseUrl: backendBaseUrl,
        token: token,
        key: action.key,
      );

      _view?.showActionSuccess(action, message);
    } catch (error) {
      _view?.showActionError(action, error);
    }
  }
}
