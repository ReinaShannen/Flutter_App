import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'feature_item.dart';

class HomeFeatures extends StatelessWidget {
  const HomeFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FeatureItem(
          icon: Icons.lock_outline,
          text: context.l10n.secureAuth,
        ),
        const SizedBox(height: 14),
        FeatureItem(
          icon: Icons.people_outline,
          text: context.l10n.manageUsersRealtime,
        ),
        const SizedBox(height: 14),
        FeatureItem(
          icon: Icons.layers_outlined,
          text: context.l10n.cleanArchitecture,
        ),
      ],
    );
  }
}
