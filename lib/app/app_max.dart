import 'package:flutter/material.dart';

import '../auth/services/auth_session.dart';
import '../auth/views/auth_gate.dart';
import '../auth/views/login_page.dart';
import '../auth/views/protected_route.dart';
import '../config/views/user_config_page.dart';
import '../home/views/home_page.dart';
import '../ui/app_theme.dart';
import '../users/models/user_record.dart';
import '../users/views/user_form_page.dart';
import '../users/views/users_page.dart';
import 'app_routes.dart';

class AppMax extends StatefulWidget {
  const AppMax({super.key});

  @override
  State<AppMax> createState() => _AppMaxState();
}

class _AppMaxState extends State<AppMax> {
  late final AuthSession _session;

  @override
  void initState() {
    super.initState();
    _session = AuthSession();
    _session.load();
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      session: _session,
      child: MaterialApp(
        title: 'App Max',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const AuthGate(),
        onGenerateRoute: (settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) {
              return switch (settings.name) {
                AppRoutes.login => const LoginPage(),
                AppRoutes.home ||
                AppRoutes.scraper => const ProtectedRoute(child: HomePage()),
                AppRoutes.config => const ProtectedRoute(
                  child: UserConfigPage(),
                ),
                AppRoutes.users => const ProtectedRoute(child: UsersPage()),
                AppRoutes.createUser => const ProtectedRoute(
                  child: UserFormPage(),
                ),
                AppRoutes.editUser => ProtectedRoute(
                  child: UserFormPage(user: settings.arguments as UserRecord?),
                ),
                _ => const AuthGate(),
              };
            },
          );
        },
      ),
    );
  }
}
