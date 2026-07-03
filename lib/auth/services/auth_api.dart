import '../../automation/models/fdc_login_command.dart';
import '../../automation/services/local_web_automation.dart';
import '../../config/models/user_config.dart';
import '../../config/services/user_config_api.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../models/login_result.dart';

class AuthApi {
  const AuthApi({LocalWebAutomation? automation, UserConfigApi? configApi})
    : _automation = automation ?? const LocalWebAutomation(),
      _configApi = configApi ?? const UserConfigApi();

  final LocalWebAutomation _automation;
  final UserConfigApi _configApi;

  Future<LoginResult> login({required LoginRequest request}) async {
    final username = request.username.trim();

    if (username.isEmpty || request.password.isEmpty) {
      throw Exception('Informe usuario e senha FDC.');
    }

    await _automation.loginFdc(
      FdcLoginCommand(
        fdcUser: username,
        fdcPass: request.password,
        headless: true,
        timeoutMs: 30000,
      ),
    );

    await _configApi.saveMyConfig(
      config: UserConfig(
        userId: 1,
        fdcUser: username,
        fdcPass: request.password,
        automationFramework: 'playwright',
        browserMode: 'visible',
        browserEngine: 'chromium',
        actionTimeoutMs: 30000,
      ),
    );

    return LoginResult(
      user: AuthUser(
        id: 1,
        name: username,
        email: '$username@fdc.local',
        role: 'operator',
        permissionLevel: 50,
        active: true,
      ),
    );
  }
}
