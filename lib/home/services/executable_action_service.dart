import '../../automation/models/fdc_login_command.dart';
import '../../automation/services/local_web_automation.dart';
import '../../config/models/user_config.dart';
import '../../config/services/user_config_api.dart';
import '../models/home_action.dart';
import 'execution_log_service.dart';

class ExecutableActionService {
  const ExecutableActionService({
    UserConfigApi? userConfigApi,
    LocalWebAutomation? automation,
    ExecutionLogService? logService,
  }) : _userConfigApi = userConfigApi ?? const UserConfigApi(),
       _automation = automation ?? const LocalWebAutomation(),
       _logService = logService ?? const ExecutionLogService();

  final UserConfigApi _userConfigApi;
  final LocalWebAutomation _automation;
  final ExecutionLogService _logService;

  Future<String> execute({required HomeAction action}) {
    return switch (action.key) {
      'test_login_scraping' => _executeFdcLogin(
        action: action,
        successMessage: 'Fazer login teste concluido no cliente',
        closeDelayMs: 1000,
      ),
      'fdc_login' => _executeFdcLogin(
        action: action,
        successMessage: 'Login FDC concluido no cliente',
      ),
      _ => throw Exception('Execucao local nao implementada: ${action.title}'),
    };
  }

  Future<String> _executeFdcLogin({
    required HomeAction action,
    required String successMessage,
    int closeDelayMs = 0,
  }) async {
    try {
      final config = await _userConfigApi.getMyConfig();
      _validateFdcConfig(config);

      final result = await _automation.loginFdc(
        FdcLoginCommand(
          fdcUser: config.fdcUser,
          fdcPass: config.fdcPass,
          headless: config.runInBackground,
          closeDelayMs: closeDelayMs,
          timeoutMs: config.actionTimeoutMs,
        ),
      );

      await _logService.record(
        key: action.key,
        title: action.title,
        success: true,
        message: successMessage,
        result: result.rawJson,
      );

      return successMessage;
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      await _tryRecordFailure(action: action, message: message);
      rethrow;
    }
  }

  void _validateFdcConfig(UserConfig config) {
    if (config.fdcUser.trim().isEmpty || config.fdcPass.isEmpty) {
      throw Exception('Configure FDC usuario e FDC senha antes de executar.');
    }
  }

  Future<void> _tryRecordFailure({
    required HomeAction action,
    required String message,
  }) async {
    try {
      await _logService.record(
        key: action.key,
        title: action.title,
        success: false,
        message: message,
      );
    } catch (_) {
      // Preserve the original local automation error for the UI.
    }
  }
}
