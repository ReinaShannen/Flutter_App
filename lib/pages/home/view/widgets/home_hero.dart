import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

class HomeHero extends StatelessWidget {
  final bool animate;

  const HomeHero({super.key, required this.animate});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;

    return Column(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 800),
          opacity: animate ? 1 : 0,
          child: Text(
            context.l10n.manageUsers,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 900),
          opacity: animate ? 1 : 0,
          child: Text(
            context.l10n.homeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
