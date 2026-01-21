import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../core/storage/app_preferences.dart';
import '../../core/storage/pref_keys.dart';
import '../../core/extensions/context_extensions.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hasSubmitted = false;
  bool _obscurePassword = true;

  final RegExp _emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        FirebaseAnalytics.instance.logEvent(
          name: 'login_success',
          parameters: {
            'user_id': user.uid,
            'method': 'email_password',
          },
        );

        await AppPreferences.putBool(PrefKeys.isLoggedIn, true);
        await AppPreferences.putString(PrefKeys.userId, user.uid);
        await AppPreferences.putString(
          PrefKeys.userName,
          user.email ?? '',
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = context.l10n.userNotFound;
          break;
        case 'wrong-password':
          message = context.l10n.wrongPassword;
          break;
        case 'invalid-email':
          message = context.l10n.invalidEmail;
          break;
        case 'user-disabled':
          message = context.l10n.userDisabled;
          break;
        default:
          message = context.l10n.loginFailed;
      }

      FirebaseAnalytics.instance.logEvent(
        name: 'login_failed',
        parameters: {
          'error_code': e.code,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔙 Back button
            Positioned(
              top: 16,
              left: 16,
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // Login Card
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _hasSubmitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.welcomeBack,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          context.l10n.loginToContinue,
                          style: textTheme.bodyMedium?.copyWith(
                            color:
                                colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: context.l10n.emailLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.l10n.emailRequired;
                            }
                            if (!_emailRegex.hasMatch(value.trim())) {
                              return context.l10n.invalidEmail;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: context.l10n.passwordLabel,
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.l10n.passwordRequired;
                            }
                            if (value.length < 6) {
                              return context.l10n.passwordTooShort;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  colorScheme.primary,
                              foregroundColor:
                                  colorScheme.onPrimary,
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _hasSubmitted = true;
                                    });

                                    FirebaseAnalytics.instance.logEvent(
                                      name: 'login_clicked',
                                    );

                                    _login();
                                  },
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color:
                                        colorScheme.onPrimary,
                                  )
                                : Text(context.l10n.login),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Register
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, '/register');
                          },
                          child: Text(
                            '${context.l10n.dontHaveAccount} ${context.l10n.register}',
                            style: TextStyle(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
