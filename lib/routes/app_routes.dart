import 'package:flutter/material.dart';

import '../pages/dashboard/view/dashboard_screen.dart';
import '../pages/login_signup/view/login_screen.dart';
import '../pages/login_signup/view/register_screen.dart';
import '../pages/splash/splash_screen.dart';
import '../pages/home/view/home_screen.dart';

class AppRoutes {
  // 🔹 Route names (constants)
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  // 🔹 Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    dashboard: (context) => const DashboardScreen(),
  };
}
