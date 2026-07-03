import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../ui/app_theme.dart';
import '../models/login_request.dart';
import '../models/login_result.dart';
import '../presenters/login_presenter.dart';
import '../services/auth_api.dart';
import '../services/auth_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements LoginView {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final LoginPresenter _presenter;

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter = LoginPresenter(api: const AuthApi());
    _presenter.attach(this);
  }

  @override
  void dispose() {
    _presenter.detach();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void setLoading(bool value) {
    if (!mounted) return;

    setState(() {
      _loading = value;
      if (value) _error = null;
    });
  }

  @override
  void showLoginSuccess(LoginResult result) {
    if (!mounted) return;

    AuthScope.of(context).signIn(user: result.user).then((
      _,
    ) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    });
  }

  @override
  void showLoginError(Object error) {
    if (!mounted) return;

    setState(() {
      _error = error.toString().replaceFirst('Exception: ', '');
    });
  }

  Future<void> _login() {
    if (_formKey.currentState?.validate() != true) {
      return Future.value();
    }

    return _presenter.login(
      request: LoginRequest(
        username: _userController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;

          if (compact) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _LoginBrand(),
                    const SizedBox(height: 56),
                    const _LoginHero(compact: true),
                    const SizedBox(height: 34),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: _LoginForm(
                          formKey: _formKey,
                          userController: _userController,
                          passwordController: _passwordController,
                          loading: _loading,
                          obscurePassword: _obscurePassword,
                          error: _error,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onLogin: _login,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF08171B),
                    border: Border(right: BorderSide(color: AppTheme.border)),
                  ),
                  padding: const EdgeInsets.all(34),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LoginBrand(),
                      Spacer(),
                      _LoginHero(),
                      Spacer(),
                      _LoginFooter(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: _LoginForm(
                      formKey: _formKey,
                      userController: _userController,
                      passwordController: _passwordController,
                      loading: _loading,
                      obscurePassword: _obscurePassword,
                      error: _error,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onLogin: _login,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.userController,
    required this.passwordController,
    required this.loading,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onLogin,
    this.error,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final bool loading;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onLogin;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'AUTENTICACAO',
            style: TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bem-vindo de volta',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Entre com suas credenciais FDC.',
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 34),
          TextFormField(
            controller: userController,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Usuario FDC',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.isEmpty) {
                return 'Informe o usuario FDC.';
              }

              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            style: const TextStyle(fontSize: 13),
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                onPressed: loading ? null : onTogglePassword,
                icon: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Informe a senha FDC.';
              }

              return null;
            },
            onFieldSubmitted: (_) => loading ? null : onLogin(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: true,
                  onChanged: loading ? null : (_) {},
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Manter conectado',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppTheme.muted, fontSize: 13),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: loading ? null : () {},
                child: const Text('Esqueci a senha'),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: loading ? null : onLogin,
            child: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Entrar'),
          ),
        ],
      ),
    );
  }
}

class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.cyanSoft,
            border: Border.all(color: const Color(0xFF0F6472)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.shield_outlined, color: AppTheme.cyan),
        ),
        const SizedBox(width: 12),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Corporate Suite',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Operations Console - v2.4',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 28.0 : 34.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ferramentas internas',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          Text(
            'unificadas.',
            style: TextStyle(
              color: AppTheme.cyan,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Acesse rotinas automatizadas, integracoes e relatorios operacionais em um unico painel desktop.',
            style: TextStyle(color: AppTheme.muted, fontSize: 15, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Text(
            '(c) 2026 Corporate Suite Ltda.',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            'Ambiente: Producao',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
