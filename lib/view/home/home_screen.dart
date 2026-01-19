import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../l10n/app_localizations.dart';

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
      setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final l10n = AppLocalizations.of(context)!;

    final bgColor = Theme.of(context).colorScheme.background;
    final textColor = Theme.of(context).colorScheme.onBackground;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // =========================
              // TOP BAR
              // =========================
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.profileManager,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        PopupMenuButton<Locale>(
                          icon: Icon(Icons.language, color: textColor),
                          onSelected: (locale) {
                            context
                                .read<LocaleProvider>()
                                .setLocale(locale);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: Locale('en'),
                              child: Text('English'),
                            ),
                            PopupMenuItem(
                              value: Locale('ta'),
                              child: Text('தமிழ்'),
                            ),
                          ],
                        ),
                        PopupMenuButton<ThemeMode>(
                          icon: Icon(Icons.color_lens, color: textColor),
                          onSelected: themeProvider.setThemeMode,
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: ThemeMode.system,
                              child: Text('System'),
                            ),
                            PopupMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            PopupMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // =========================
              // CONTENT
              // =========================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: _animate ? 1 : 0,
                        child: Text(
                          l10n.manageUsers,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 900),
                        opacity: _animate ? 1 : 0,
                        child: Text(
                          l10n.homeSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      Column(
                        children: [
                          FeatureItem(
                            icon: Icons.lock_outline,
                            text: l10n.secureAuth,
                          ),
                          const SizedBox(height: 14),
                          FeatureItem(
                            icon: Icons.people_outline,
                            text: l10n.manageUsersRealtime,
                          ),
                          const SizedBox(height: 14),
                          FeatureItem(
                            icon: Icons.layers_outlined,
                            text: l10n.cleanArchitecture,
                          ),
                        ],
                      ),

                      const Spacer(),

                      _actionButton(
                        context,
                        text: l10n.login,
                        color: primaryColor,
                        onTap: () =>
                            Navigator.pushNamed(context, '/login'),
                      ),
                      const SizedBox(height: 16),
                      _actionButton(
                        context,
                        text: l10n.register,
                        color: primaryColor,
                        onTap: () =>
                            Navigator.pushNamed(context, '/register'),
                      ),
                      const SizedBox(height: 16),
                      _actionButton(
                        context,
                        text: l10n.forceCrash,
                        color: Colors.red,
                        onTap: () {
                          FirebaseCrashlytics.instance.crash();
                        },
                      ),

                      const SizedBox(height: 24),

                      Text(
                        l10n.trustText,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(letterSpacing: 1.2)),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).colorScheme.onBackground;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
