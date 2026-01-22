import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
