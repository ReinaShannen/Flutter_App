import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets /app_loader.dart';
import '../../core/widgets /logout_dialog.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../dashboard/dashboard_actions.dart';
import 'widgets/dashboard_user_card.dart';
import '../../model/dashboard_user.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// 🔹 Cache decoded image to prevent blinking
  MemoryImage? profileImage;
  String? username;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserViewModel>().loadAllUsers();
      _loadProfileData();
    });
  }

  /// Loads logged-in user's profile info ONCE
  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      final base64 = doc.data()?['profileImageBase64'];

      setState(() {
        username = doc.data()?['username'];
        profileImage = base64 != null && base64.isNotEmpty
            ? MemoryImage(ImageUtils.decodeBase64(base64))
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 🔹 APP BAR + PROFILE (NO BLINKING)
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                title: Text(context.l10n.dashboard),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => LogoutDialog.show(context),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.only(top: 90),
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
                          backgroundImage: profileImage,
                          child: profileImage == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          username ?? '',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          currentUser?.email ?? '',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔹 USERS GRID (Selector – no full rebuild)
              Selector<UserViewModel, List<DashboardUser>>(
                selector: (_, vm) => vm.combinedUsers,
                builder: (_, users, __) {
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = users[index];
                          return DashboardUserCard(
                            user: user,
                            onLongPress: () {
                              DashboardActions.showUserActionBottomSheet(
                                context,
                                context.read<UserViewModel>(),
                                user,
                              );
                            },
                          );
                        },
                        childCount: users.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // 🔹 LOADER (initial + action loading)
          Selector<UserViewModel, bool>(
            selector: (_, vm) =>
                vm.isInitialLoading || vm.isActionLoading,
            builder: (_, isLoading, __) {
              if (!isLoading) return const SizedBox.shrink();
              return const AppLoader();
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => DashboardActions.showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
