import 'package:flutter/material.dart';
import 'package:flutter_app/core/extensions/context_extensions.dart';

class HomeActions extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onCrash;

  const HomeActions({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onCrash,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        _actionButton(
          text: context.l10n.login,
          color: primaryColor,
          onTap: onLogin,
        ),
        const SizedBox(height: 16),
        _actionButton(
          text: context.l10n.register,
          color: primaryColor,
          onTap: onRegister,
        ),
        const SizedBox(height: 16),
        _actionButton(
          text: context.l10n.forceCrash,
          color: Colors.red,
          onTap: onCrash,
        ),
      ],
    );
  }

  Widget _actionButton({
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
