import 'package:flutter/material.dart';
import '../../view_model/auth_viewmodel.dart';
import '../../../../core/extensions/context_extensions.dart';

class RegisterFormFields extends StatefulWidget {
  final AuthViewModel authVM;
  final RegExp emailRegex;
  final RegExp passwordRegex;

  const RegisterFormFields({
    super.key,
    required this.authVM,
    required this.emailRegex,
    required this.passwordRegex,
  });

  @override
  State<RegisterFormFields> createState() => _RegisterFormFieldsState();
}

class _RegisterFormFieldsState extends State<RegisterFormFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authVM = widget.authVM;

    return Column(
      children: [
        // 🔹 Username
        TextFormField(
          controller: authVM.usernameController,
          decoration: InputDecoration(
            labelText: l10n.username,
            border: const OutlineInputBorder(),
            errorMaxLines: 2,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.usernameRequired;
            }
            if (value.trim().length < 3) {
              return l10n.usernameMinLength;
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 🔹 Email
        TextFormField(
          controller: authVM.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.email,
            border: const OutlineInputBorder(),
            errorMaxLines: 2,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.emailRequired;
            }
            if (!widget.emailRegex.hasMatch(value.trim())) {
              return l10n.invalidEmail;
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 🔹 Password
        TextFormField(
          controller: authVM.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.password,
            border: const OutlineInputBorder(),
            errorMaxLines: 2,
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
              return l10n.passwordRequired;
            }
            if (value.length < 6 || value.length > 20) {
              return l10n.passwordLength;
            }
            if (!widget.passwordRegex.hasMatch(value)) {
              return l10n.passwordStrength;
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 🔹 Confirm Password
        TextFormField(
          controller: authVM.confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: l10n.confirmPassword,
            border: const OutlineInputBorder(),
            errorMaxLines: 2,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword =
                      !_obscureConfirmPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }
            if (value != authVM.passwordController.text) {
              return l10n.passwordMismatch;
            }
            return null;
          },
        ),
      ],
    );
  }
}
