import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../auth/services/auth_session.dart';
import '../../config/services/user_config_api.dart';
import '../models/scrape_request.dart';
import '../models/scrape_result.dart';
import '../presenters/scraper_presenter.dart';
import '../services/scraper_api.dart';

class ScraperPage extends StatefulWidget {
  const ScraperPage({super.key});

  @override
  State<ScraperPage> createState() => _ScraperPageState();
}

class _ScraperPageState extends State<ScraperPage> implements ScraperView {
  final _urlController = TextEditingController(text: 'https://example.com');
  final _clickController = TextEditingController();
  final _extractController = TextEditingController(text: 'body');
  final _waitController = TextEditingController();
  final _configApi = const UserConfigApi();

  late final ScraperPresenter _presenter;

  bool _headless = false;
  bool _configLoaded = false;
  int _timeoutMs = 30000;
  bool _loading = false;
  String _status = 'Pronto para executar.';
  String _result = '';

  @override
  void initState() {
    super.initState();
    _presenter = ScraperPresenter(api: const ScraperApi());
    _presenter.attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_configLoaded) return;

    _configLoaded = true;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadAutomationConfig(),
    );
  }

  @override
  void dispose() {
    _presenter.detach();
    _urlController.dispose();
    _clickController.dispose();
    _extractController.dispose();
    _waitController.dispose();
    super.dispose();
  }

  @override
  void setLoading(bool value) {
    if (!mounted) return;

    setState(() {
      _loading = value;
    });
  }

  @override
  void showScrapeStarted() {
    if (!mounted) return;

    setState(() {
      _status = 'Executando automacao local...';
      _result = '';
    });
  }

  @override
  void showScrapeResult(ScrapeResult result) {
    if (!mounted) return;

    setState(() {
      _status = result.status;
      _result = result.rawJson;
    });
  }

  @override
  void showScrapeError(Object error) {
    if (!mounted) return;

    setState(() {
      _status = 'Erro ao executar automacao local.';
      _result = error.toString();
    });
  }

  Future<void> _runScrape() {
    return _presenter.runScrape(
      request: ScrapeRequest(
        url: _urlController.text.trim(),
        clickSelector: _clickController.text.trim(),
        extractSelector: _extractController.text.trim(),
        waitForSelector: _waitController.text.trim(),
        headless: _headless,
        timeoutMs: _timeoutMs,
      ),
    );
  }

  Future<void> _loadAutomationConfig() async {
    try {
      final config = await _configApi.getMyConfig();

      if (!mounted) return;
      setState(() {
        _headless = config.runInBackground;
        _timeoutMs = config.actionTimeoutMs;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = 'Usando configuracao local padrao.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final session = AuthScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Max'),
        backgroundColor: colorScheme.surface,
        actions: [
          if (session.user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text(session.user!.role)),
            ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _loading
                ? null
                : () async {
                    await session.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Automacao web local',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Background'),
                    value: _headless,
                    onChanged: _loading
                        ? null
                        : (value) => setState(() => _headless = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'URL',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clickController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Seletor para clique',
                      hintText: 'button[type="submit"]',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _waitController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Esperar seletor',
                      hintText: '.resultado',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _extractController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Seletor para extrair texto',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _runScrape,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_loading ? 'Executando' : 'Executar'),
            ),
            const SizedBox(height: 12),
            Text(_status),
            const SizedBox(height: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _result.isEmpty
                        ? 'O retorno da automacao local aparece aqui.'
                        : _result,
                    style: const TextStyle(fontFamily: 'Consolas'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
