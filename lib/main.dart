import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';

// ViewModels
import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // 🔹 User CRUD ViewModel
        ChangeNotifierProvider(
          create: (_) => UserViewModel(),
        ),

        // 🔹 Auth (Login / Register) ViewModel
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Profile Management App',
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
