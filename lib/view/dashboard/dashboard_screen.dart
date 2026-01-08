import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

    // Load users from API → Firestore
    Future.microtask(() {
      Provider.of<UserViewModel>(context, listen: false).loadUsers();
      _loadProfileData();
    });
  }

  // Load profile data from Firestore (logged-in user)
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
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async {
        // Close app instead of going back
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              SystemNavigator.pop(); 
            },
          ),
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
                color: Colors.purple.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.purple.shade100,
                    backgroundImage:
                        profileImageBase64 != null && profileImageBase64!.isNotEmpty
                            ? MemoryImage(decodeBase64Image(profileImageBase64!))
                            : null,
                    child: profileImageBase64 == null ||
                            profileImageBase64!.isEmpty
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username ?? '',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.email ?? '',
                    style:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =======================
            // USERS TITLE
            // =======================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Users',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // =======================
            // USERS LIST (Firestore Stream)
            // =======================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users_cache')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;

                      final int id = int.parse(docs[index].id);

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(data['name'] ?? ''),
                          subtitle: Text(data['email'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () {
                                  _showEditDialog(
                                    context,
                                    userVM,
                                    id,
                                    data['name'],
                                    data['email'],
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () async {
                                  await userVM.deleteUser(id);
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

        // =======================
        // ADD USER BUTTON
        // =======================
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddDialog(context, userVM);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // =======================
  // ADD USER DIALOG
  // =======================
  void _showAddDialog(BuildContext context, UserViewModel userVM) {
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
  // EDIT USER DIALOG
  // =======================
  void _showEditDialog(
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
}



// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../viewmodel/user_viewmodel.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String? profileImageBase64;
//   String? username;

//   @override
//   void initState() {
//     super.initState();

//     Future.microtask(() {
//       Provider.of<UserViewModel>(context, listen: false).loadUsers();
//       _loadProfileData();
//     });
//   }

//   // Load profile data from Firestore
//   Future<void> _loadProfileData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('user')
//           .doc(user.uid)
//           .get();

//       if (doc.exists) {
//         setState(() {
//           profileImageBase64 = doc.data()?['profileImageBase64'];
//           username = doc.data()?['username'];
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading profile data: $e');
//     }
//   }

  
//   Uint8List decodeBase64Image(String base64String) {
//     final cleanedBase64 = base64String.contains(',')
//         ? base64String.split(',').last
//         : base64String;

//     return base64Decode(cleanedBase64);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userVM = Provider.of<UserViewModel>(context);
//     final currentUser = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           // TOP PROFILE SECTION
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 24),
//             decoration: BoxDecoration(
//               color: Colors.purple.shade50,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(24),
//                 bottomRight: Radius.circular(24),
//               ),
//             ),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundColor: Colors.purple.shade100,
//                   backgroundImage:
//                       profileImageBase64 != null && profileImageBase64!.isNotEmpty
//                           ? MemoryImage(decodeBase64Image(profileImageBase64!))
//                           : null,
//                   child: profileImageBase64 == null ||
//                           profileImageBase64!.isEmpty
//                       ? const Icon(Icons.person, size: 40)
//                       : null,
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   username ?? '',
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   currentUser?.email ?? '',
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           // CRUD TITLE
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Users',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),

//           const SizedBox(height: 8),

//           // 🔹 CRUD LIST
//           Expanded(
//             child: userVM.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: userVM.users.length,
//                     itemBuilder: (context, index) {
//                       final user = userVM.users[index];

//                       return Card(
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                         child: ListTile(
//                           leading: const CircleAvatar(
//                             child: Icon(Icons.person),
//                           ),
//                           title: Text(user.name),
//                           subtitle: Text(user.email),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.edit,
//                                     color: Colors.blue),
//                                 onPressed: () {
//                                   _showEditDialog(context, userVM, user);
//                                 },
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete,
//                                     color: Colors.red),
//                                 onPressed: () {
//                                   userVM.deleteUser(user.id);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),

//       //  ADD USER BUTTON
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddDialog(context, userVM);
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   void _showAddDialog(BuildContext context, UserViewModel userVM) {
//     final nameController = TextEditingController();
//     final emailController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Add User'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               userVM.createUser(
//                 nameController.text.trim(),
//                 emailController.text.trim(),
//               );
//               Navigator.pop(context);
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditDialog(BuildContext context, UserViewModel userVM, user) {
//     final nameController = TextEditingController(text: user.name);
//     final emailController = TextEditingController(text: user.email);

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Edit User'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               userVM.updateUser(
//                 user.id,
//                 nameController.text.trim(),
//                 emailController.text.trim(),
//               );
//               Navigator.pop(context);
//             },
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }
// }



