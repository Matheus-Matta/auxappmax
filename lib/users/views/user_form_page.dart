import 'package:flutter/material.dart';

import '../../auth/services/auth_session.dart';
import '../../ui/app_theme.dart';
import '../models/user_payload.dart';
import '../models/user_record.dart';
import '../services/users_api.dart';

class UserFormPage extends StatelessWidget {
  const UserFormPage({this.user, super.key});

  final UserRecord? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user == null ? 'Novo usuario' : 'Editar usuario'),
      ),
      body: Center(
        child: UserFormPanel(
          user: user,
          onCancel: () => Navigator.of(context).pop(),
          onSaved: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class UserFormPanel extends StatefulWidget {
  const UserFormPanel({this.user, this.onCancel, this.onSaved, super.key});

  final UserRecord? user;
  final VoidCallback? onCancel;
  final VoidCallback? onSaved;

  @override
  State<UserFormPanel> createState() => _UserFormPanelState();
}

class _UserFormPanelState extends State<UserFormPanel> {
  final _api = const UsersApi();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _active = true;
  bool _loading = false;
  String _role = 'viewer';
  String? _error;

  bool get _editing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _role = user.role;
      _active = user.active;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;

    final session = AuthScope.of(context);
    final token = session.token;
    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final payload = UserPayload(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
      active: _active,
    );

    try {
      if (_editing) {
        await _api.updateUser(
          backendBaseUrl: session.backendBaseUrl,
          token: token,
          id: widget.user!.id,
          payload: payload,
        );
      } else {
        await _api.createUser(
          backendBaseUrl: session.backendBaseUrl,
          token: token,
          payload: payload,
        );
      }

      if (!mounted) return;
      widget.onSaved?.call();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                  Text(
                    _editing ? 'Editar usuario' : 'Novo usuario',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) => (value ?? '').trim().length < 2
                        ? 'Informe o nome.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => !(value ?? '').contains('@')
                        ? 'Informe um email valido.'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(fontSize: 13),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _editing ? 'Nova senha' : 'Senha',
                      hintText: _editing ? 'Deixe em branco para manter' : null,
                    ),
                    validator: (value) {
                      final text = value ?? '';
                      if (!_editing && text.length < 8) {
                        return 'A senha deve ter pelo menos 8 caracteres.';
                      }
                      if (_editing && text.isNotEmpty && text.length < 8) {
                        return 'A senha deve ter pelo menos 8 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: const InputDecoration(labelText: 'Perfil'),
                    style: const TextStyle(fontSize: 13),
                    isDense: true,
                    items: const [
                      DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                      DropdownMenuItem(
                        value: 'operator',
                        child: Text('Operator'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: _loading
                        ? null
                        : (value) => setState(() => _role = value!),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: AppTheme.controlHeight,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _active,
                            onChanged: _loading
                                ? null
                                : (value) => setState(() => _active = value!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Usuario ativo',
                          style: TextStyle(color: AppTheme.muted, fontSize: 13),
                        ),
                      ],
                    ),
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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 96,
                        child: TextButton(
                          onPressed: _loading ? null : widget.onCancel,
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        height: AppTheme.controlHeight,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _save,
                          icon: _loading
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 18),
                          label: Text(_editing ? 'Salvar' : 'Criar usuario'),
                        ),
                      ),
                    ],
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
