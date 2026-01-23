import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_app/pages/home/view/widgets/home_actions.dart';
import 'package:flutter_app/pages/home/view/widgets/home_features.dart';
import 'package:flutter_app/pages/home/view/widgets/home_hero.dart';
import 'package:flutter_app/pages/home/view/widgets/home_top_bar.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/extensions/context_extensions.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              HomeTopBar(themeProvider: themeProvider),

 Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const SizedBox(height: 32),

                HomeHero(animate: _animate),

                const SizedBox(height: 48),

                const HomeFeatures(),

                const Spacer(),

                HomeActions(
                  onLogin: () =>
                      Navigator.pushNamed(context, '/login'),
                  onRegister: () =>
                      Navigator.pushNamed(context, '/register'),
                  onCrash: () =>
                      FirebaseCrashlytics.instance.crash(),
                ),

                const SizedBox(height: 24),

                Text(
                  context.l10n.trustText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    },
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}
