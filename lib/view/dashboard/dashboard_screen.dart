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

    try {
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
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Uint8List decodeBase64Image(String base64String) {
    final cleanedBase64 = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;

    return base64Decode(cleanedBase64);
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
          title: Text(
            'Dashboard',
            style: TextStyle(color: colorScheme.onPrimary),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: colorScheme.onPrimary),
              onPressed: () {
                LogoutDialog.show(context);
              },
            ),
          ],
        ),

        body: Column(
          children: [
            // =======================
            // TOP PROFILE SECTION
            // =======================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.onPrimary.withOpacity(0.2),
                    backgroundImage: profileImageBase64 != null &&
                            profileImageBase64!.isNotEmpty
                        ? MemoryImage(decodeBase64Image(profileImageBase64!))
                        : null,
                    child: profileImageBase64 == null ||
                            profileImageBase64!.isEmpty
                        ? Icon(Icons.person,
                            size: 40, color: colorScheme.onPrimary)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username ?? '',
                    style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.email ?? '',
                    style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.7),
                        ) ??
                        TextStyle(
                          fontSize: 14,
                          color: colorScheme.onPrimary.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Users',
                  style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ) ??
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // =======================
            // COMBINED USERS LIST
            // =======================
            Expanded(
              child: Consumer<UserViewModel>(
                builder: (context, userVM, _) {
                  if (userVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userVM.combinedUsers.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: userVM.combinedUsers.length,
                    itemBuilder: (context, index) {
                      final user = userVM.combinedUsers[index];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            backgroundImage: user.profileImageBase64 != null &&
                                    user.profileImageBase64!.isNotEmpty
                                ? MemoryImage(
                                    base64Decode(user.profileImageBase64!),
                                  )
                                : null,
                            child: user.profileImageBase64 == null ||
                                    user.profileImageBase64!.isEmpty
                                ? Icon(Icons.person,
                                    color: colorScheme.onPrimary)
                                : null,
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: colorScheme.primary),
                                onPressed: () {
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
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  if (user.isRegistered) {
                                    await userVM.deleteRegisteredUser(user.id);
                                  } else {
                                    await userVM.deleteUser(int.parse(user.id));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: colorScheme.primary,
          onPressed: () {
            _showAddDialog(context);
          },
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
    );
  }

  // =======================
  // ADD API USER
  // =======================
  void _showAddDialog(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
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

  // =======================
  // EDIT API USER
  // =======================
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

  // =======================
  // EDIT REGISTERED USER
  // =======================
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
