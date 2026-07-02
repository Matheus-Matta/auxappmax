import 'package:flutter/material.dart';

import '../../auth/services/auth_session.dart';
import '../../ui/app_theme.dart';
import '../models/user_config.dart';
import '../services/user_config_api.dart';

class UserConfigPage extends StatelessWidget {
  const UserConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: Padding(padding: EdgeInsets.all(24), child: UserConfigPanel()),
      ),
    );
  }
}

class UserConfigPanel extends StatefulWidget {
  const UserConfigPanel({super.key});

  @override
  State<UserConfigPanel> createState() => _UserConfigPanelState();
}

class _UserConfigPanelState extends State<UserConfigPanel> {
  final _api = const UserConfigApi();
  final _formKey = GlobalKey<FormState>();
  final _fdcUserController = TextEditingController();
  final _fdcPassController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _obscurePass = true;
  String? _error;
  String? _success;
  UserConfig? _config;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConfig());
  }

  @override
  void dispose() {
    _fdcUserController.dispose();
    _fdcPassController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final session = AuthScope.of(context);
    final token = session.token;

    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final config = await _api.getMyConfig(
        backendBaseUrl: session.backendBaseUrl,
        token: token,
      );

      if (!mounted) return;
      _fdcUserController.text = config.fdcUser;
      _fdcPassController.text = config.fdcPass;
      setState(() => _config = config);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState?.validate() != true) return;

    final session = AuthScope.of(context);
    final token = session.token;
    final user = session.user;

    if (token == null || user == null) return;

    setState(() {
      _saving = true;
      _error = null;
      _success = null;
    });

    try {
      final saved = await _api.saveMyConfig(
        backendBaseUrl: session.backendBaseUrl,
        token: token,
        config: UserConfig(
          id: _config?.id,
          userId: user.id,
          fdcUser: _fdcUserController.text.trim(),
          fdcPass: _fdcPassController.text,
        ),
      );

      if (!mounted) return;
      setState(() {
        _config = saved;
        _success = 'Configuracoes salvas.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.panel,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.cyanSoft,
                          border: Border.all(color: const Color(0xFF0F6472)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: AppTheme.cyan,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Configuracoes',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (_loading)
                        const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fdcUserController,
                    enabled: !_loading && !_saving,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'FDC usuario',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Informe o usuario FDC.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _fdcPassController,
                    enabled: !_loading && !_saving,
                    obscureText: _obscurePass,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'FDC senha',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        tooltip: _obscurePass
                            ? 'Mostrar senha'
                            : 'Ocultar senha',
                        onPressed: _loading || _saving
                            ? null
                            : () {
                                setState(() => _obscurePass = !_obscurePass);
                              },
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                      ),
                    ),
                    validator: (value) =>
                        (value ?? '').isEmpty ? 'Informe a senha FDC.' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (_success != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _success!,
                      style: const TextStyle(
                        color: AppTheme.cyan,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 132,
                      height: AppTheme.controlHeight,
                      child: FilledButton.icon(
                        onPressed: _loading || _saving ? null : _saveConfig,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Salvar'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
