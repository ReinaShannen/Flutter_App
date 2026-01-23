  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../../core/extensions/context_extensions.dart';
  import '../view_model/user_viewmodel.dart';

  class DashboardActions {


    // =======================
    // USER ACTION BOTTOM SHEET
    // =======================
    static void showUserActionBottomSheet(
        BuildContext context,
        UserViewModel userVM,
        dynamic user,
        ) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(context.l10n.editUser),
                onTap: () {
                  print("Reg user DIALOG,${user.isRegistered}");
                  Navigator.pop(context);
                  if (user.isRegistered) {
                    showEditRegisteredDialog(
                      context,
                      userVM,
                      user.id,
                      user.name,
                      user.email,
                    );
                  } else {
                    showEditApiDialog(
                      context,
                      userVM,
                      user.id, // 🔥 Now passing String ID
                      user.name,
                      user.email,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(context.l10n.deleteUser),
                onTap: () {
                  Navigator.pop(context);
                  showDeleteConfirmation(context, userVM, user);
                },
              ),
            ],
          );
        },
      );
    }

    // =======================
    // DELETE CONFIRMATION
    // =======================
    static void showDeleteConfirmation(
        BuildContext context,
        UserViewModel userVM,
        dynamic user,
        ) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.l10n.deleteUser),
          content: Text(context.l10n.deleteConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                if (user.isRegistered) {
                  userVM.deleteRegisteredUser(user.id);
                } else {
                  userVM.deleteUser(user.id); // 🔥 Now accepts String ID
                }
              },
              child: Text(context.l10n.delete),
            ),
          ],
        ),
      );
    }

    // =======================
    // ADD USER
    // =======================
    static void showAddDialog(BuildContext context) {
      final userVM = context.read<UserViewModel>();
      final nameCtrl = TextEditingController();
      final emailCtrl = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.l10n.addUser),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.usernameLabel,
                  hintText: context.l10n.usernameHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.l10n.emailLabel,
                  hintText: context.l10n.emailHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')), // Quick fix
                  );
                  return;
                }
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 50));

                await userVM.createUser(
                  nameCtrl.text.trim(),
                  emailCtrl.text.trim(),
                );
                //Navigator.pop(context);
              },
              child: Text(context.l10n.add),
            ),
          ],
        ),
      );
    }

    // =======================
    // EDIT API USER
    // =======================
    static void showEditApiDialog(
        BuildContext context,
        UserViewModel userVM,
        String firestoreId,
        String currentName,
        String currentEmail,
        ) {
      final nameCtrl = TextEditingController(text: currentName);
      final emailCtrl = TextEditingController(text: currentEmail);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.l10n.editUser),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.usernameLabel,
                  hintText: context.l10n.usernameHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.l10n.emailLabel,
                  hintText: context.l10n.emailHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')), // Quick fix
                  );
                  return;
                }

                Navigator.pop(context);
                userVM.updateUser(
                  firestoreId,
                  nameCtrl.text.trim(),
                  emailCtrl.text.trim(),
                );
              },
              child: Text(context.l10n.update),
            ),
          ],
        ),
      );
    }

    // =======================
    // EDIT REGISTERED USER
    // =======================
    static void showEditRegisteredDialog(
        BuildContext context,
        UserViewModel userVM,
        String uid,
        String currentName,
        String currentEmail,
        ) {
      final nameCtrl = TextEditingController(text: currentName);
      final emailCtrl = TextEditingController(text: currentEmail);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.l10n.editRegisteredUser),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.usernameLabel,
                  hintText: context.l10n.usernameHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.l10n.emailLabel,
                  hintText: context.l10n.emailHint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')), // Quick fix
                  );
                  return;
                }

                Navigator.pop(context);
                userVM.updateRegisteredUser(
                  uid,
                  nameCtrl.text.trim(),
                  emailCtrl.text.trim(),
                );
              },
              child: Text(context.l10n.update),
            ),
          ],
        ),
      );
    }
  }