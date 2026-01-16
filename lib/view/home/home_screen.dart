import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';

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
      setState(() {
        _animate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bgColor = Theme.of(context).colorScheme.background;
    final textColor = Theme.of(context).colorScheme.onBackground;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // =========================
              // TOP BAR WITH THEME SWITCH
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile Manager',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    PopupMenuButton<ThemeMode>(
                      icon: Icon(Icons.color_lens, color: textColor),
                      onSelected: (mode) {
                        themeProvider.setThemeMode(mode);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: ThemeMode.system,
                          child: Text('System Theme'),
                        ),
                        PopupMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light Theme'),
                        ),
                        PopupMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark Theme'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // =========================
              // MAIN CONTENT
              // =========================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // 🔹 Animated Title
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: _animate ? 1 : 0,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 800),
                          offset: _animate
                              ? Offset.zero
                              : const Offset(0, -0.2),
                          child: Text(
                            'Manage users easily',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 Animated Subtitle
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 900),
                        opacity: _animate ? 1 : 0,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 900),
                          offset: _animate
                              ? Offset.zero
                              : const Offset(0, -0.2),
                          child: Text(
                            'Authentication & data powered by\nFlutter and Firebase',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // 🔹 Feature list
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        opacity: _animate ? 1 : 0,
                        child: Column(
                          children: const [
                            FeatureItem(
                              icon: Icons.lock_outline,
                              text: 'Secure Firebase Authentication',
                            ),
                            SizedBox(height: 14),
                            FeatureItem(
                              icon: Icons.people_outline,
                              text: 'Manage users in real-time',
                            ),
                            SizedBox(height: 14),
                            FeatureItem(
                              icon: Icons.layers_outlined,
                              text: 'Clean MVVM architecture',
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 🔹 Buttons
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 900),
                        opacity: _animate ? 1 : 0,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 900),
                          offset: _animate
                              ? Offset.zero
                              : const Offset(0, 0.3),
                          child: Column(
                            children: [
                              _actionButton(
                                context,
                                text: 'LOGIN',
                                color: primaryColor,
                                onTap: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                              ),
                              const SizedBox(height: 16),
                              _actionButton(
                                context,
                                text: 'REGISTER',
                                color: primaryColor,
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                              ),
                              const SizedBox(height: 16),
                              _actionButton(
                                context,
                                text: 'FORCE CRASH',
                                color: Colors.red,
                                onTap: () {
                                  FirebaseCrashlytics.instance.crash();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 🔹 Trust text
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 1200),
                        opacity: _animate ? 1 : 0,
                        child: Text(
                          'Secure • Fast • Firebase Auth',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
        child: Text(
          text,
          style: const TextStyle(letterSpacing: 1.2),
        ),
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
    final textColor = Theme.of(context).colorScheme.onBackground;

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
