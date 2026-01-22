import 'package:flutter/material.dart';

import '../view/splash/splash_screen.dart';
import '../view/home/home_screen.dart';
import '../view/auth/login/login_screen.dart';
import '../view/auth/register/register_screen.dart';
import '../view/dashboard/dashboard_screen.dart';

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
