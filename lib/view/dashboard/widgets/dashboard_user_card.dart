import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/image_utils.dart';

class DashboardUserCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback onLongPress;

  const DashboardUserCard({
    super.key,
    required this.user,
    required this.onLongPress,
  });

  Uint8List _decodeBase64Image(String base64String) {
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
              backgroundImage: user.profileImageBase64?.isNotEmpty == true
                  ? MemoryImage(
                      ImageUtils.decodeBase64(user.profileImageBase64),
                    )
                  : null,

                  
              child: user.profileImageBase64 == null
                  ? const Icon(Icons.person)
                  : null,
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
