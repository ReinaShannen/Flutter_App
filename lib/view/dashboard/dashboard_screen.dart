import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/widgets /logout_dialog.dart';
import '../../viewmodel/user_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? profileImageBase64;
  String? username;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<UserViewModel>(context, listen: false).loadAllUsers();
      _loadProfileData();
    });
  }

  // =======================
  // LOAD LOGGED IN USER PROFILE
  // =======================
  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        profileImageBase64 = doc.data()?['profileImageBase64'];
        username = doc.data()?['username'];
      });
    }
  }

  Uint8List decodeBase64Image(String base64String) {
    final cleanedBase64 = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(cleanedBase64);
  }

  // USER ACTION BOTTOM SHEET

  void _showUserActionBottomSheet(
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit User'),
                onTap: () {
                  Navigator.pop(context);
                  if (user.isRegistered) {
                    _showEditRegisteredDialog(
                      context,
                      userVM,
                      user.id,
                      user.name,
                      user.email,
                    );
                  } else {
                    _showEditApiDialog(
                      context,
                      userVM,
                      int.parse(user.id),
                      user.name,
                      user.email,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete User'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, userVM, user);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  
  // DELETE CONFIRMATION DIALOG 

  void _showDeleteConfirmation(
    BuildContext context,
    UserViewModel userVM,
    dynamic user,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); 

              if (user.isRegistered) {
                userVM.deleteRegisteredUser(user.id);
              } else {
                userVM.deleteUser(int.parse(user.id));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          title: Text('Dashboard',
              style: TextStyle(color: colorScheme.onPrimary)),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: colorScheme.onPrimary),
              onPressed: () => LogoutDialog.show(context),
            ),
          ],
        ),
        body: Consumer<UserViewModel>(
          builder: (context, userVM, _) {
            if (userVM.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: userVM.combinedUsers.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final user = userVM.combinedUsers[index];

                return GestureDetector(
                  onLongPress: () =>
                      _showUserActionBottomSheet(context, userVM, user),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colorScheme.primary,
                            backgroundImage: user.profileImageBase64 != null &&
                                    user.profileImageBase64!.isNotEmpty
                                ? MemoryImage(
                                    base64Decode(user.profileImageBase64!))
                                : null,
                            child: user.profileImageBase64 == null ||
                                    user.profileImageBase64!.isEmpty
                                ? Icon(Icons.person,
                                    color: colorScheme.onPrimary)
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: colorScheme.primary,
          onPressed: () => _showAddDialog(context),
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
    );
  }

  // =======================
  // ADD USER DIALOG
  // =======================
  void _showAddDialog(BuildContext context) {
    final userVM = context.read<UserViewModel>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await userVM.createUser(
                nameController.text.trim(),
                emailController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditApiDialog(
    BuildContext context,
    UserViewModel userVM,
    int id,
    String currentName,
    String currentEmail,
  ) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await userVM.updateUser(
                id,
                nameController.text.trim(),
                emailController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditRegisteredDialog(
    BuildContext context,
    UserViewModel userVM,
    String uid,
    String currentName,
    String currentEmail,
  ) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Registered User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await userVM.updateRegisteredUser(
                uid,
                nameController.text.trim(),
                emailController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
