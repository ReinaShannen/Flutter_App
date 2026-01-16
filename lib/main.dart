import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/core/services/api_service.dart';
import 'package:provider/provider.dart';
import 'core/storage/app_preferences.dart';
import 'core/storage/pref_keys.dart';
import 'core/services/remote_config_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui';
import 'core/theme/app_themes.dart';


import 'firebase_options.dart';
import 'routes/app_routes.dart';

import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/auth_viewmodel.dart';

import 'core/theme/theme_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  await AppPreferences.init();
  await RemoteConfigService.init();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(
    MultiProvider(
      providers: [
        // User CRUD ViewModel
        ChangeNotifierProvider(
          create: (_) => UserViewModel(ApiService()),
        ),

        // Auth (Login / Register) ViewModel
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = ThemeProvider();
            return provider;
          },
        ),


    ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 return Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Profile Management App',

      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,

      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  },
);


  }
}


