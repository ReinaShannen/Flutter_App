import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pages/login_signup/view_model/auth_viewmodel.dart';
import '../../core/extensions/context_extensions.dart';

class LogoutDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.confirmLogoutTitle),
        content: Text(context.l10n.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final authVM =
                  Provider.of<AuthViewModel>(context, listen: false);

              await authVM.logout();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child:Text(
              context.l10n.logout,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
