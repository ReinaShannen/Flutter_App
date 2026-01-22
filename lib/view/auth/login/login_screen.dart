import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_extensions.dart';
import 'login_viewmodel.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/login_button.dart';
import 'widgets/login_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _hasSubmitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    context.read<LoginViewModel>().login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      errorMessages: {
        'user-not-found': l10n.userNotFound,
        'wrong-password': l10n.wrongPassword,
        'invalid-email': l10n.invalidEmail,
        'user-disabled': l10n.userDisabled,
        'default': l10n.loginFailed,
      },
      onSuccess: () {
        navigator.pushReplacementNamed('/dashboard');
      },
      onError: (message) {
        messenger.showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ BACK BUTTON IS NOW SAFE IN ALL ORIENTATIONS
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: _hasSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginHeader(
                    title: context.l10n.welcomeBack,
                    subtitle: context.l10n.loginToContinue,
                  ),

                  const SizedBox(height: 32),

                  LoginForm(
                    emailController: _emailCtrl,
                    passwordController: _passwordCtrl,
                  ),

                  const SizedBox(height: 24),

                  LoginButton(
                    isLoading: vm.isLoading,
                    label: context.l10n.login,
                    onPressed: () {
                      setState(() => _hasSubmitted = true);
                      _onLogin();
                    },
                  ),

                  const SizedBox(height: 16),
                  const LoginFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
