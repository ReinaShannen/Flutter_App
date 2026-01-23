import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';

class SplashFooter extends StatelessWidget {
  final bool isLandscape;

  const SplashFooter({
    super.key,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isLandscape ? 16 : 32,
        horizontal: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

           Text(
    context.l10n.profileManager,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          CircularProgressIndicator(
            color: Color.fromRGBO(126, 15, 230, 1),
          ),
        ],
      ),
    );
  }
}
