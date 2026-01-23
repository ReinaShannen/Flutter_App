import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../model/dashboard_user.dart';


class DashboardUserCard extends StatelessWidget {
  final DashboardUser user;
  final VoidCallback onLongPress;

  const DashboardUserCard({
    super.key,
    required this.user,
    required this.onLongPress,
  });

  Uint8List _decodeBase64(String base64String) {
    final cleaned = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: user.profileImageBase64 != null &&
                        user.profileImageBase64!.isNotEmpty
                    ? Image.memory(
                        _decodeBase64(user.profileImageBase64!),
                        key: ValueKey(user.id), 
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : const Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              user.name,
              style: textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              user.email,
              style: textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
