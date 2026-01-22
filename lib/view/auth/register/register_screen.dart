import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../viewmodel/auth_viewmodel.dart';
import '../../../core/extensions/context_extensions.dart';
import '../register/widgets/reg_profile_avatar.dart';
import 'widgets/register_form_fields.dart';
import 'widgets/register_button.dart';
import '../register/widgets/register_footer.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    // 🔹 Regex patterns (UNCHANGED)
    final RegExp emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    final RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[_\W]).{6,20}$',
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.register),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: double.infinity,
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
                key: authVM.formKey,
                autovalidateMode: authVM.hasSubmitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 PROFILE IMAGE
                    RegisterProfileAvatar(authVM: authVM),

                    const SizedBox(height: 30),

                    // 🔹 FORM FIELDS
                    RegisterFormFields(
                      authVM: authVM,
                      emailRegex: emailRegex,
                      passwordRegex: passwordRegex,
                    ),

                    const SizedBox(height: 30),

                    // 🔹 REGISTER BUTTON
                    RegisterButton(authVM: authVM),

                    const SizedBox(height: 16),
                    const RegisterFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
