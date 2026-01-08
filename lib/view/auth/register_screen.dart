import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../core/theme/app_button_styles.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    // 🔹 Regex patterns
    final RegExp emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    final RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[_\W]).{6,20}$',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEDE3FF),
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: authVM.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: authVM.profileImage != null
                              ? FileImage(authVM.profileImage!)
                              : null,
                          child: authVM.profileImage == null
                              ? const Icon(Icons.person, size: 55)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: authVM.pickImage,
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFFD8C8FF),
                              child: Icon(Icons.camera_alt, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 🔹 Username
                    TextFormField(
                      controller: authVM.usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        errorMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Minimum 3 characters required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Email
                    TextFormField(
                      controller: authVM.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        errorMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Password
                    TextFormField(
                      controller: authVM.passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        errorMaxLines: 2, // 👈 IMPORTANT FIX
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6 || value.length > 20) {
                          return '6–20 characters required';
                        }
                        if (!passwordRegex.hasMatch(value)) {
                          return 'Use atleast 1 upper, lower, number & special character';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Confirm Password
                    TextFormField(
                      controller: authVM.confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        errorMaxLines: 2,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm your password';
                        }
                        if (value != authVM.passwordController.text) {
                          return 'Passwords do not match';
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
                        style: AppButtonStyles.primaryLilacButton,
                        onPressed: authVM.isLoading
                            ? null
                            : () async {
                                if (!authVM.formKey.currentState!.validate()) {
                                  return;
                                }

                                final error = await authVM.registerUser();

                                if (error == null && context.mounted) {
                                  Navigator.pushReplacementNamed(
                                      context, '/dashboard');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Registration successful'),
                                    ),
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error ?? 'Error'),
                                    ),
                                  );
                                }
                              },
                        child: authVM.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('REGISTER'),
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
