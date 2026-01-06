import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_button_styles.dart';

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
    // Trigger animations after build
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _animate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background2.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),

                    // Animated Title
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: _animate ? 1 : 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 800),
                        offset: _animate ? Offset.zero : const Offset(0, -0.2),
                        child: const Text(
                          'Manage users easily',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                        offset: _animate ? Offset.zero : const Offset(0, -0.2),
                        child: const Text(
                          'Authentication & data powered by\nFlutter and Firebase',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 🔹 Feature list (staggered)
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

                    // Animated Buttons
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 900),
                      opacity: _animate ? 1 : 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 900),
                        offset: _animate ? Offset.zero : const Offset(0, 0.3),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: AppButtonStyles.primaryLilacButton,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text(
                                  'LOGIN',
                                  style: TextStyle(letterSpacing: 1.2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: AppButtonStyles.primaryLilacButton,
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'REGISTER',
                              style: TextStyle(letterSpacing: 1.2),
                            ),
                          ),
                        ),

                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    //  Trust text
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 1200),
                      opacity: _animate ? 1 : 0,
                      child: const Text(
                        'Secure • Fast • Firebase Auth',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
