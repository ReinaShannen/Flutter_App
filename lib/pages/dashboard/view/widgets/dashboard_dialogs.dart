import 'package:flutter/material.dart';
import 'package:flutter_app/pages/dashboard/view_model/user_viewmodel.dart';
import 'package:flutter_app/core/extensions/context_extensions.dart';

class DashboardDialogs {
  static void showUserActions(
    BuildContext context,
    UserViewModel userVM,
    dynamic user,
    Function onEdit,
    Function onDelete,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(context.l10n.editUser),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(context.l10n.deleteUser),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
