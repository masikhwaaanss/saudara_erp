import 'package:flutter/material.dart';
import 'package:saudara_erp/features/auth/pages/splash_page.dart';
import 'package:saudara_erp/features/auth/pages/login_page.dart';
import 'package:saudara_erp/features/dashboard/pages/dashboard_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
