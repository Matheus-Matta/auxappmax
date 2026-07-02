import '../models/login_request.dart';
import '../models/login_result.dart';
import '../services/auth_api.dart';

abstract class LoginView {
  void setLoading(bool value);
  void showLoginSuccess(LoginResult result);
  void showLoginError(Object error);
}

class LoginPresenter {
  LoginPresenter({required AuthApi api}) : _api = api;

  final AuthApi _api;
  LoginView? _view;

  void attach(LoginView view) {
    _view = view;
  }

  void detach() {
    _view = null;
  }

  Future<void> login({
    required String backendBaseUrl,
    required LoginRequest request,
  }) async {
    _view?.setLoading(true);

    try {
      final result = await _api.login(
        backendBaseUrl: backendBaseUrl,
        request: request,
      );
      _view?.showLoginSuccess(result);
    } catch (error) {
      _view?.showLoginError(error);
    } finally {
      _view?.setLoading(false);
    }
  }
}
