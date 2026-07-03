import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../auth/services/auth_session.dart';
import '../../config/views/user_config_page.dart';
import '../../ui/app_theme.dart';
import '../../users/models/user_record.dart';
import '../../users/views/user_form_page.dart';
import '../../users/views/users_page.dart';
import '../models/execution_report.dart';
import '../models/home_action.dart';
import '../models/home_activity.dart';
import '../models/home_dashboard.dart';
import '../models/home_metric.dart';
import '../presenters/execution_reports_presenter.dart';
import '../presenters/home_presenter.dart';

enum _ShellPage {
  dashboard,
  quickActions,
  integrations,
  users,
  userForm,
  reports,
  config,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements HomeView {
  late final HomePresenter _presenter;

  _ShellPage _page = _ShellPage.dashboard;
  UserRecord? _editingUser;
  String? _runningActionKey;
  List<HomeAction> _actions = fallbackHomeActions;
  List<HomeMetric> _metrics = const [
    HomeMetric(label: 'Jobs hoje', value: '0', meta: 'execucoes'),
    HomeMetric(label: 'Sucesso', value: '100,0%', meta: '0/0'),
    HomeMetric(label: 'Executaveis', value: '8', meta: 'fallback'),
    HomeMetric(label: 'Usuarios', value: '0', meta: 'offline'),
  ];
  final List<HomeActivity> _activities = const [
    HomeActivity(
      time: '--:--',
      title: 'Aguardando execucoes locais',
      status: 'Info',
    ),
  ].toList();

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter();
    _presenter.attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  @override
  void dispose() {
    _presenter.detach();
    super.dispose();
  }

  @override
  void showDashboardLoaded(HomeDashboard dashboard) {
    if (!mounted) return;

    setState(() {
      _actions = dashboard.actions.isEmpty
          ? fallbackHomeActions
          : dashboard.actions;
      _metrics = dashboard.metrics;
      _activities
        ..clear()
        ..addAll(dashboard.activities);
      if (_activities.isEmpty) {
        _activities.add(
          const HomeActivity(
            time: '--:--',
            title: 'Nenhuma atividade registrada ainda',
            status: 'Info',
          ),
        );
      }
    });
  }

  @override
  void showDashboardError(Object error) {
    if (!mounted) return;
  }

  @override
  void showActionStarted(HomeAction action) {
    if (!mounted) return;

    setState(() {
      _runningActionKey = action.key;
    });
  }

  @override
  void showActionSuccess(HomeAction action, String message) {
    if (!mounted) return;

    setState(() {
      _runningActionKey = null;
      _activities.insert(
        0,
        HomeActivity(time: _now(), title: message, status: 'Sucesso'),
      );
    });
    _loadDashboard();
  }

  @override
  void showActionError(HomeAction action, Object error) {
    if (!mounted) return;

    setState(() {
      _runningActionKey = null;
      _activities.insert(
        0,
        HomeActivity(
          time: _now(),
          title: '${action.title} falhou',
          status: 'Erro',
        ),
      );
    });
  }

  Future<void> _execute(HomeAction action) {
    return _presenter.execute(action: action);
  }

  Future<void> _loadDashboard() {
    return _presenter.loadDashboard();
  }

  void _showDashboard() {
    setState(() {
      _page = _ShellPage.dashboard;
      _editingUser = null;
    });
  }

  void _showUsers() {
    setState(() {
      _page = _ShellPage.users;
      _editingUser = null;
    });
  }

  void _showQuickActions() {
    setState(() {
      _page = _ShellPage.quickActions;
      _editingUser = null;
    });
  }

  void _showIntegrations() {
    setState(() {
      _page = _ShellPage.integrations;
      _editingUser = null;
    });
  }

  void _showReports() {
    setState(() {
      _page = _ShellPage.reports;
      _editingUser = null;
    });
  }

  void _showCreateUser() {
    setState(() {
      _page = _ShellPage.userForm;
      _editingUser = null;
    });
  }

  void _showEditUser(UserRecord user) {
    setState(() {
      _page = _ShellPage.userForm;
      _editingUser = user;
    });
  }

  void _showConfig() {
    setState(() {
      _page = _ShellPage.config;
      _editingUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compactSidebar = constraints.maxWidth < 980;
          final compactHeader = constraints.maxWidth < 760;
          final compactTopBar = constraints.maxWidth < 820;
          final pagePadding = constraints.maxWidth < 900 ? 20.0 : 48.0;

          return Row(
            children: [
              _Sidebar(
                compact: compactSidebar,
                selectedPage: _page,
                onDashboard: _showDashboard,
                userRole: session.user?.role ?? 'operador',
                onConfig: _showConfig,
                onIntegrations: _showIntegrations,
                onQuickActions: _showQuickActions,
                onReports: _showReports,
                onUsers: _showUsers,
                onSignOut: () async {
                  await session.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
              ),
              const VerticalDivider(width: 1, color: AppTheme.border),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(compact: compactTopBar),
                    Expanded(
                      child: _ShellContent(
                        compactHeader: compactHeader,
                        editingUser: _editingUser,
                        page: _page,
                        pagePadding: pagePadding,
                        userName: session.user?.name ?? 'Usuario',
                        actions: _actions,
                        activities: _activities,
                        metrics: _metrics,
                        runningActionKey: _runningActionKey,
                        onExecute: _execute,
                        onCreateUser: _showCreateUser,
                        onEditUser: _showEditUser,
                        onUserFormCancel: _showUsers,
                        onUserFormSaved: _showUsers,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _now() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ShellContent extends StatelessWidget {
  const _ShellContent({
    required this.actions,
    required this.activities,
    required this.compactHeader,
    required this.editingUser,
    required this.metrics,
    required this.onCreateUser,
    required this.onEditUser,
    required this.onExecute,
    required this.onUserFormCancel,
    required this.onUserFormSaved,
    required this.page,
    required this.pagePadding,
    required this.runningActionKey,
    required this.userName,
  });

  final List<HomeAction> actions;
  final List<HomeActivity> activities;
  final bool compactHeader;
  final UserRecord? editingUser;
  final List<HomeMetric> metrics;
  final VoidCallback onCreateUser;
  final void Function(UserRecord user) onEditUser;
  final Future<void> Function(HomeAction action) onExecute;
  final VoidCallback onUserFormCancel;
  final VoidCallback onUserFormSaved;
  final _ShellPage page;
  final double pagePadding;
  final String? runningActionKey;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final content = switch (page) {
      _ShellPage.dashboard => _DashboardPanel(
        actions: actions,
        activities: activities,
        compactHeader: compactHeader,
        metrics: metrics,
        onExecute: onExecute,
        runningActionKey: runningActionKey,
        userName: userName,
      ),
      _ShellPage.quickActions => _QuickActionsPanel(
        actions: actions,
        runningActionKey: runningActionKey,
        onExecute: onExecute,
      ),
      _ShellPage.integrations => const _IntegrationsPanel(),
      _ShellPage.users => UsersPanel(
        onCreate: onCreateUser,
        onEdit: onEditUser,
      ),
      _ShellPage.userForm => UserFormPanel(
        key: ValueKey(editingUser?.id ?? 'new-user'),
        user: editingUser,
        onCancel: onUserFormCancel,
        onSaved: onUserFormSaved,
      ),
      _ShellPage.reports => const _ReportsPanel(),
      _ShellPage.config => const UserConfigPanel(),
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(pagePadding, 34, pagePadding, 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: content,
        ),
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.actions,
    required this.activities,
    required this.compactHeader,
    required this.metrics,
    required this.onExecute,
    required this.runningActionKey,
    required this.userName,
  });

  final List<HomeAction> actions;
  final List<HomeActivity> activities;
  final bool compactHeader;
  final List<HomeMetric> metrics;
  final Future<void> Function(HomeAction action) onExecute;
  final String? runningActionKey;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(compact: compactHeader, userName: userName),
          const SizedBox(height: 28),
          _Metrics(metrics: metrics),
          const SizedBox(height: 34),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Funcoes executaveis',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton(onPressed: () {}, child: const Text('Ver todas')),
            ],
          ),
          const SizedBox(height: 14),
          _ActionGrid(
            actions: actions,
            runningActionKey: runningActionKey,
            onExecute: onExecute,
          ),
          const SizedBox(height: 34),
          Text(
            'Atividade recente',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _ActivityList(activities: activities),
        ],
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel({
    required this.actions,
    required this.onExecute,
    required this.runningActionKey,
  });

  final List<HomeAction> actions;
  final Future<void> Function(HomeAction action) onExecute;
  final String? runningActionKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PageTitle(
            icon: Icons.play_arrow_outlined,
            title: 'Acoes rapidas',
            subtitle: 'Rotinas executaveis do ambiente operacional.',
          ),
          const SizedBox(height: 18),
          _ActionGrid(
            actions: actions,
            runningActionKey: runningActionKey,
            onExecute: onExecute,
          ),
        ],
      ),
    );
  }
}

class _IntegrationsPanel extends StatelessWidget {
  const _IntegrationsPanel();

  static const _items = [
    _IntegrationItem(
      title: 'FDC',
      subtitle: 'Credenciais configuradas por usuario',
      status: 'Configuravel',
      icon: Icons.key_outlined,
    ),
    _IntegrationItem(
      title: 'Backend local',
      subtitle: 'API Node para usuarios, configs e dados',
      status: 'Ativo',
      icon: Icons.dns_outlined,
    ),
    _IntegrationItem(
      title: 'Banco de dados',
      subtitle: 'SQLite em dev e Postgres em producao',
      status: 'Migrado',
      icon: Icons.storage_outlined,
    ),
    _IntegrationItem(
      title: 'Playwright',
      subtitle: 'Navegador executado no cliente Windows',
      status: 'Pronto',
      icon: Icons.public_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PageTitle(
            icon: Icons.storage_outlined,
            title: 'Integracoes',
            subtitle: 'Servicos e conexoes usados pelas rotinas internas.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 2 : 1;
              final width =
                  (constraints.maxWidth - (14 * (columns - 1))) / columns;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final item in _items)
                    SizedBox(
                      width: width,
                      height: 126,
                      child: _IntegrationCard(item: item),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportsPanel extends StatefulWidget {
  const _ReportsPanel();

  @override
  State<_ReportsPanel> createState() => _ReportsPanelState();
}

class _ReportsPanelState extends State<_ReportsPanel>
    implements ExecutionReportsView {
  static const _pageSize = 20;

  late final ExecutionReportsPresenter _presenter;

  List<ExecutionReport> _runs = const [];
  bool _loading = true;
  int _offset = 0;
  int _total = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter = ExecutionReportsPresenter();
    _presenter.attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReports());
  }

  @override
  void dispose() {
    _presenter.detach();
    super.dispose();
  }

  @override
  void setReportsLoading(bool value) {
    if (!mounted) return;

    setState(() => _loading = value);
  }

  @override
  void showReportsLoaded(ExecutionReportPage page) {
    if (!mounted) return;

    setState(() {
      _runs = page.runs;
      _offset = page.offset;
      _total = page.total;
    });
  }

  @override
  void showReportsError(Object error) {
    if (!mounted) return;

    setState(() {
      _error = error.toString().replaceFirst('Exception: ', '');
    });
  }

  Future<void> _loadReports({int? offset}) async {
    setState(() {
      _error = null;
    });

    return _presenter.loadReports(limit: _pageSize, offset: offset ?? _offset);
  }

  void _previousPage() {
    final nextOffset = (_offset - _pageSize).clamp(0, _total);
    _loadReports(offset: nextOffset);
  }

  void _nextPage() {
    final nextOffset = _offset + _pageSize;
    if (nextOffset >= _total) return;
    _loadReports(offset: nextOffset);
  }

  @override
  Widget build(BuildContext context) {
    final start = _total == 0 ? 0 : _offset + 1;
    final end = (_offset + _runs.length).clamp(0, _total);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PageTitle(
            icon: Icons.article_outlined,
            title: 'Relatorios',
            subtitle: 'Arquivos operacionais e historico recente.',
          ),
          const SizedBox(height: 18),
          _Panel(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Resultados das execucoes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Atualizar',
                        onPressed: _loading ? null : () => _loadReports(),
                        icon: const Icon(Icons.refresh, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const SizedBox(
                      height: 92,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  else if (_runs.isEmpty)
                    const SizedBox(
                      height: 92,
                      child: Center(
                        child: Text(
                          'Nenhuma execucao registrada.',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final run in _runs) _ExecutionReportRow(run: run),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Mostrando $start-$end de $_total',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Pagina anterior',
                        onPressed: _loading || _offset == 0
                            ? null
                            : _previousPage,
                        icon: const Icon(Icons.chevron_left, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Proxima pagina',
                        onPressed: _loading || _offset + _runs.length >= _total
                            ? null
                            : _nextPage,
                        icon: const Icon(Icons.chevron_right, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutionReportRow extends StatelessWidget {
  const _ExecutionReportRow({required this.run});

  final ExecutionReport run;

  @override
  Widget build(BuildContext context) {
    final statusColor = run.success ? AppTheme.cyan : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 54,
                child: Text(
                  run.time,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  run.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  border: Border.all(color: statusColor),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  run.status,
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
              ),
            ],
          ),
          if (run.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              run.message,
              style: const TextStyle(color: AppTheme.muted, fontSize: 13),
            ),
          ],
          if (run.resultPreview != '-') ...[
            const SizedBox(height: 8),
            SelectableText(
              run.resultPreview,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontFamily: 'Consolas',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    required this.icon,
    required this.subtitle,
    required this.title,
  });

  final IconData icon;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.cyanSoft,
            border: Border.all(color: const Color(0xFF0F6472)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppTheme.cyan, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({required this.item});

  final _IntegrationItem item;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, color: AppTheme.cyan, size: 19),
                const Spacer(),
                _StatusBadge(label: item.status),
              ],
            ),
            const Spacer(),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.subtitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.cyanSoft,
        border: Border.all(color: const Color(0xFF0F6472)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.cyan, fontSize: 12),
      ),
    );
  }
}

class _IntegrationItem {
  const _IntegrationItem({
    required this.icon,
    required this.status,
    required this.subtitle,
    required this.title,
  });

  final IconData icon;
  final String status;
  final String subtitle;
  final String title;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.compact,
    required this.selectedPage,
    required this.onDashboard,
    required this.onConfig,
    required this.onIntegrations,
    required this.onQuickActions,
    required this.onReports,
    required this.onUsers,
    required this.userRole,
    required this.onSignOut,
  });

  final bool compact;
  final _ShellPage selectedPage;
  final VoidCallback onDashboard;
  final VoidCallback onConfig;
  final VoidCallback onIntegrations;
  final VoidCallback onQuickActions;
  final VoidCallback onReports;
  final VoidCallback onUsers;
  final String userRole;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 76 : 236,
      child: ColoredBox(
        color: AppTheme.panel,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Brand(compact: compact),
              const SizedBox(height: 28),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                label: 'Dashboard',
                compact: compact,
                selected: selectedPage == _ShellPage.dashboard,
                onTap: onDashboard,
              ),
              _NavItem(
                icon: Icons.play_arrow_outlined,
                label: 'Acoes rapidas',
                compact: compact,
                selected: selectedPage == _ShellPage.quickActions,
                onTap: onQuickActions,
              ),
              _NavItem(
                icon: Icons.storage_outlined,
                label: 'Integracoes',
                compact: compact,
                selected: selectedPage == _ShellPage.integrations,
                onTap: onIntegrations,
              ),
              _NavItem(
                icon: Icons.people_outline,
                label: 'Usuarios',
                compact: compact,
                selected:
                    selectedPage == _ShellPage.users ||
                    selectedPage == _ShellPage.userForm,
                onTap: onUsers,
              ),
              _NavItem(
                icon: Icons.article_outlined,
                label: 'Relatorios',
                compact: compact,
                selected: selectedPage == _ShellPage.reports,
                onTap: onReports,
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Configuracoes',
                compact: compact,
                selected: selectedPage == _ShellPage.config,
                onTap: onConfig,
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(compact ? 8 : 12),
                decoration: BoxDecoration(
                  color: AppTheme.panelSoft,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: compact
                    ? IconButton(
                        tooltip: 'Sair',
                        onPressed: onSignOut,
                        icon: const Icon(Icons.logout, size: 18),
                      )
                    : Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: AppTheme.cyan,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              userRole.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sair',
                            onPressed: onSignOut,
                            icon: const Icon(Icons.logout, size: 18),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: compact
                      ? 'Buscar...'
                      : 'Buscar funcao, relatorio, integracao...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: compact ? 8 : 18),
          IconButton(
            tooltip: 'Notificacoes',
            onPressed: () {},
            icon: const Badge(
              smallSize: 7,
              backgroundColor: AppTheme.cyan,
              child: Icon(Icons.notifications_none_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Configuracoes',
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.compact, required this.userName});

  final bool compact;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final firstName = userName.trim().split(' ').first;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAINEL DE OPERACOES',
          style: TextStyle(
            color: AppTheme.muted,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Bom dia, $firstName',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Todas as integracoes estao operacionais. Ultima verificacao ha 2 minutos.',
          style: TextStyle(color: AppTheme.muted, fontSize: 15),
        ),
      ],
    );

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: AppTheme.cyan),
          SizedBox(width: 8),
          Text('Sistema estavel', style: TextStyle(color: AppTheme.muted)),
        ],
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: badge),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        const SizedBox(width: 16),
        badge,
      ],
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.metrics});

  final List<HomeMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final width = (constraints.maxWidth - (16 * (columns - 1))) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: width,
                  child: _MetricCard(
                    label: metric.label,
                    value: metric.value,
                    meta: metric.meta,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.meta,
  });

  final String label;
  final String value;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      height: 86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  meta,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.cyan, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.actions,
    required this.runningActionKey,
    required this.onExecute,
  });

  final List<HomeAction> actions;
  final String? runningActionKey;
  final Future<void> Function(HomeAction action) onExecute;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980
            ? 4
            : constraints.maxWidth >= 720
            ? 3
            : constraints.maxWidth >= 460
            ? 2
            : 1;
        final width = (constraints.maxWidth - (14 * (columns - 1))) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final action in actions)
              SizedBox(
                width: width,
                height: 162,
                child: _ActionCard(
                  action: action,
                  running: runningActionKey == action.key,
                  disabled: runningActionKey != null || !action.enabled,
                  onExecute: onExecute,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.action,
    required this.running,
    required this.disabled,
    required this.onExecute,
  });

  final HomeAction action;
  final bool running;
  final bool disabled;
  final Future<void> Function(HomeAction action) onExecute;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: disabled ? null : () => onExecute(action),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: running
                        ? const Padding(
                            padding: EdgeInsets.all(9),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(action.icon, color: AppTheme.cyan, size: 19),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      action.badge,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                action.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                running ? 'Executando...' : action.subtitle,
                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.activities});

  final List<HomeActivity> activities;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          for (final activity in activities.take(6))
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(
                      activity.time,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cyanSoft,
                      border: Border.all(color: const Color(0xFF0F6472)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      activity.status,
                      style: const TextStyle(
                        color: AppTheme.cyan,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.compact,
    this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.cyanSoft : Colors.transparent,
            border: Border.all(
              color: selected ? const Color(0xFF0F6472) : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppTheme.cyan : AppTheme.muted,
              ),
              if (!compact) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppTheme.cyan : AppTheme.muted,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.cyanSoft,
            border: Border.all(color: const Color(0xFF0F6472)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: AppTheme.cyan,
            size: 20,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Corporate Suite',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.panel,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: height == null ? EdgeInsets.zero : const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
