import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../login_signup/view_model/auth_viewmodel.dart';
import '../../core/services/remote_config_service.dart';
import 'widgets/splash_footer.dart';
import 'widgets/splash_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadRemoteConfigAndCheckSession();
  }

  Future<void> _loadRemoteConfigAndCheckSession() async {
    await Future.delayed(const Duration(seconds: 10));

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final isLoggedIn = authVM.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? '/dashboard' : '/home',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return const Column(
                children: [
                  Expanded(child: SplashAnimation()),
                  SplashFooter(),
                ],
              );
            } else {
              return const Row(
                children: [
                  Expanded(child: SplashAnimation()),
                  SplashFooter(isLandscape: true),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
