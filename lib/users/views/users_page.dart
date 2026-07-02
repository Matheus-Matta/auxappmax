import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../auth/services/auth_session.dart';
import '../../ui/app_theme.dart';
import '../models/user_record.dart';
import '../services/users_api.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.home),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Dashboard'),
          ),
        ],
      ),
      body: const Padding(padding: EdgeInsets.all(24), child: UsersPanel()),
    );
  }
}

class UsersPanel extends StatefulWidget {
  const UsersPanel({this.onCreate, this.onEdit, super.key});

  final VoidCallback? onCreate;
  final void Function(UserRecord user)? onEdit;

  @override
  State<UsersPanel> createState() => _UsersPanelState();
}

class _UsersPanelState extends State<UsersPanel> {
  final _api = const UsersApi();
  final _searchController = TextEditingController();

  Timer? _debounce;
  bool _loading = true;
  String? _error;
  List<UserRecord> _users = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final session = AuthScope.of(context);
    final token = session.token;

    if (token == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await _api.listUsers(
        backendBaseUrl: session.backendBaseUrl,
        token: token,
        search: _searchController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _users = users);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _deleteUser(UserRecord user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir usuario'),
        content: Text('Confirma a exclusao de ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          SizedBox(
            width: 92,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final session = AuthScope.of(context);
    final token = session.token;
    if (token == null) return;

    try {
      await _api.deleteUser(
        backendBaseUrl: session.backendBaseUrl,
        token: token,
        id: user.id,
      );
      await _loadUsers();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _openCreate() async {
    if (widget.onCreate != null) {
      widget.onCreate!();
      return;
    }

    await Navigator.of(context).pushNamed(AppRoutes.createUser);
    if (!mounted) return;
    await _loadUsers();
  }

  Future<void> _openEdit(UserRecord user) async {
    if (widget.onEdit != null) {
      widget.onEdit!(user);
      return;
    }

    await Navigator.of(context).pushNamed(AppRoutes.editUser, arguments: user);
    if (!mounted) return;
    await _loadUsers();
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _loadUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 640;

            final search = TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Filtrar usuarios',
                prefixIcon: Icon(Icons.search, size: 18),
              ),
            );
            final button = SizedBox(
              width: compact ? double.infinity : 154,
              height: AppTheme.controlHeight,
              child: FilledButton.icon(
                onPressed: _openCreate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Novo usuario'),
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [search, const SizedBox(height: 10), button],
              );
            }

            return Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 10),
                button,
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _UsersTable(
                  users: _users,
                  onEdit: _openEdit,
                  onDelete: _deleteUser,
                ),
        ),
      ],
    );
  }
}

class _UsersTable extends StatelessWidget {
  const _UsersTable({
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  final List<UserRecord> users;
  final void Function(UserRecord user) onEdit;
  final void Function(UserRecord user) onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth > 760
            ? constraints.maxWidth
            : 760.0;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.panel,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: ListView(
                  children: [
                    DataTable(
                      dataTextStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      headingTextStyle: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                      columns: const [
                        DataColumn(label: Text('Nome')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Perfil')),
                        DataColumn(label: Text('Nivel')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Acoes')),
                      ],
                      rows: [
                        for (final user in users)
                          DataRow(
                            cells: [
                              DataCell(Text(user.name)),
                              DataCell(Text(user.email)),
                              DataCell(Text(user.role)),
                              DataCell(Text('${user.permissionLevel}')),
                              DataCell(Text(user.active ? 'Ativo' : 'Inativo')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Editar',
                                      onPressed: () => onEdit(user),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 17,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Excluir',
                                      onPressed: () => onDelete(user),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
