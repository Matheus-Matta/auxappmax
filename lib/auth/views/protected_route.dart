import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../services/auth_session.dart';

class ProtectedRoute extends StatelessWidget {
  const ProtectedRoute({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);

    if (session.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!session.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = ModalRoute.of(context)?.settings.name;

        if (route != AppRoutes.login) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
