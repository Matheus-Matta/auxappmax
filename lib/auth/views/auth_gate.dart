import 'package:flutter/material.dart';

import '../../home/views/home_page.dart';
import '../services/auth_session.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.of(context);

    if (session.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!session.isAuthenticated) {
      return const LoginPage();
    }

    return const HomePage();
  }
}
