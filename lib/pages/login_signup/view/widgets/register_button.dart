import 'package:flutter/material.dart';
import '../../view_model/auth_viewmodel.dart';
import '../../../../core/extensions/context_extensions.dart';


class RegisterButton extends StatelessWidget {
  final AuthViewModel authVM;

  const RegisterButton({
    super.key,
    required this.authVM,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return SizedBox(
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
                    context,
                    '/dashboard',
                  );

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
    );
  }
}
