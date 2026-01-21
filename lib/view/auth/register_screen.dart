import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../core/extensions/context_extensions.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    // 🔹 Regex patterns
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
                    // 🔹 Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor:
                              colorScheme.onSurface.withOpacity(0.1),
                          backgroundImage: authVM.profileImage != null
                              ? FileImage(authVM.profileImage!)
                              : null,
                          child: authVM.profileImage == null
                              ? Icon(
                                  Icons.person,
                                  size: 55,
                                  color:
                                      colorScheme.onSurface.withOpacity(0.6),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: authVM.pickImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: colorScheme.primary,
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

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
                        if (!emailRegex.hasMatch(value.trim())) {
                          return l10n.invalidEmail;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Password
                    TextFormField(
                      controller: authVM.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        border: const OutlineInputBorder(),
                        errorMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 6 || value.length > 20) {
                          return l10n.passwordLength;
                        }
                        if (!passwordRegex.hasMatch(value)) {
                          return l10n.passwordStrength;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Confirm Password
                    TextFormField(
                      controller: authVM.confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.confirmPassword,
                        border: const OutlineInputBorder(),
                        errorMaxLines: 2,
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

                    const SizedBox(height: 30),

                    // 🔹 REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        onPressed: authVM.isLoading
                            ? null
                            : () async {
                                authVM.hasSubmitted = true;
                                authVM.notifyListeners();

                                if (!authVM.formKey.currentState!.validate()) {
                                  return;
                                }

                                final error = await authVM.registerUser();

                                if (error == null && context.mounted) {
                                  Navigator.pushReplacementNamed(
                                      context, '/dashboard');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(l10n.registrationSuccessful),
                                    ),
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(error ?? l10n.errorGeneric),
                                    ),
                                  );
                                }
                              },
                        child: authVM.isLoading
                            ? CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                              )
                            : Text(l10n.register),
                      ),
                    ),
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
