import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/register');
      },
      child: Text(
        '${l10n.dontHaveAccount} ${l10n.register}',
        style: TextStyle(color: colorScheme.primary),
      ),
    );
  }
}
