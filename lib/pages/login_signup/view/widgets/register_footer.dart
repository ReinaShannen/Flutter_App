import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return TextButton(
      onPressed: () {

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      },
      child: Text(
        '${l10n.alreadyHaveAccount} ${l10n.login}',
        style: TextStyle(color: colorScheme.primary),
      ),
    );
  }
}
