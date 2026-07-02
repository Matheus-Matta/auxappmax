import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_max/main.dart';

void main() {
  Future<void> setSurfaceSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('mostra login como tela inicial sem sessao', (tester) async {
    await setSurfaceSize(tester, const Size(800, 600));
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AppMax());
    await tester.pumpAndSettle();

    expect(find.text('Corporate Suite'), findsOneWidget);
    expect(find.text('Entrar'), findsAtLeastNWidgets(1));
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });

  testWidgets('mostra home quando existe sessao salva', (tester) async {
    await setSurfaceSize(tester, const Size(1280, 720));
    SharedPreferences.setMockInitialValues({
      'auth.backend': 'http://localhost:3333',
      'auth.token': 'token-teste',
      'auth.user': jsonEncode({
        'id': 1,
        'name': 'Admin App Max',
        'email': 'admin@appmax.local',
        'role': 'admin',
        'permissionLevel': 100,
        'active': true,
      }),
    });

    await tester.pumpWidget(const AppMax());
    await tester.pumpAndSettle();

    expect(find.text('Painel de operacoes'), findsNothing);
    expect(find.text('PAINEL DE OPERACOES'), findsOneWidget);
    expect(find.text('Funcoes executaveis'), findsOneWidget);
    expect(find.text('Sincronizar Base'), findsOneWidget);
  });

  testWidgets('sidebar abre lista de usuarios no painel principal', (
    tester,
  ) async {
    await setSurfaceSize(tester, const Size(1280, 720));
    SharedPreferences.setMockInitialValues({
      'auth.backend': 'http://localhost:3333',
      'auth.token': 'token-teste',
      'auth.user': jsonEncode({
        'id': 1,
        'name': 'Admin App Max',
        'email': 'admin@appmax.local',
        'role': 'admin',
        'permissionLevel': 100,
        'active': true,
      }),
    });

    await tester.pumpWidget(const AppMax());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuarios').first);
    await tester.pumpAndSettle();

    expect(find.text('Filtrar usuarios'), findsOneWidget);
    expect(find.text('Novo usuario'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Funcoes executaveis'), findsNothing);
  });

  testWidgets('novo usuario abre formulario no painel principal', (
    tester,
  ) async {
    await setSurfaceSize(tester, const Size(1280, 720));
    SharedPreferences.setMockInitialValues({
      'auth.backend': 'http://localhost:3333',
      'auth.token': 'token-teste',
      'auth.user': jsonEncode({
        'id': 1,
        'name': 'Admin App Max',
        'email': 'admin@appmax.local',
        'role': 'admin',
        'permissionLevel': 100,
        'active': true,
      }),
    });

    await tester.pumpWidget(const AppMax());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuarios').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo usuario'));
    await tester.pumpAndSettle();

    expect(find.text('Novo usuario'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Criar usuario'), findsOneWidget);
    expect(find.text('PAINEL DE OPERACOES'), findsNothing);
  });

  testWidgets('sidebar abre configuracoes no painel principal', (tester) async {
    await setSurfaceSize(tester, const Size(1280, 720));
    SharedPreferences.setMockInitialValues({
      'auth.backend': 'http://localhost:3333',
      'auth.token': 'token-teste',
      'auth.user': jsonEncode({
        'id': 1,
        'name': 'Admin App Max',
        'email': 'admin@appmax.local',
        'role': 'admin',
        'permissionLevel': 100,
        'active': true,
      }),
    });

    await tester.pumpWidget(const AppMax());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configuracoes'));
    await tester.pumpAndSettle();

    expect(find.text('FDC usuario'), findsOneWidget);
    expect(find.text('FDC senha'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('PAINEL DE OPERACOES'), findsNothing);
  });

  testWidgets('sidebar abre paginas operacionais restantes', (tester) async {
    await setSurfaceSize(tester, const Size(1280, 720));
    SharedPreferences.setMockInitialValues({
      'auth.backend': 'http://localhost:3333',
      'auth.token': 'token-teste',
      'auth.user': jsonEncode({
        'id': 1,
        'name': 'Admin App Max',
        'email': 'admin@appmax.local',
        'role': 'admin',
        'permissionLevel': 100,
        'active': true,
      }),
    });

    await tester.pumpWidget(const AppMax());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acoes rapidas'));
    await tester.pumpAndSettle();
    expect(
      find.text('Rotinas executaveis do ambiente operacional.'),
      findsOneWidget,
    );
    expect(find.text('Baixar Backup'), findsOneWidget);

    await tester.tap(find.text('Integracoes'));
    await tester.pumpAndSettle();
    expect(
      find.text('Servicos e conexoes usados pelas rotinas internas.'),
      findsOneWidget,
    );
    expect(find.text('FDC'), findsOneWidget);
    expect(find.text('Playwright'), findsOneWidget);

    await tester.tap(find.text('Relatorios'));
    await tester.pumpAndSettle();
    expect(
      find.text('Arquivos operacionais e historico recente.'),
      findsOneWidget,
    );
    expect(find.text('Gerar PDF'), findsOneWidget);
    expect(find.text('Auditoria'), findsOneWidget);
  });

  testWidgets('home adapta em tela estreita', (tester) async {
    await setSurfaceSize(tester, const Size(700, 600));
    SharedPreferences.setMockInitialValues({
      'auth.backend': 'http://localhost:3333',
      'auth.token': 'token-teste',
      'auth.user': jsonEncode({
        'id': 1,
        'name': 'Admin App Max',
        'email': 'admin@appmax.local',
        'role': 'admin',
        'permissionLevel': 100,
        'active': true,
      }),
    });

    await tester.pumpWidget(const AppMax());
    await tester.pumpAndSettle();

    expect(find.text('PAINEL DE OPERACOES'), findsOneWidget);
    expect(find.text('Sincronizar Base'), findsOneWidget);
  });
}
