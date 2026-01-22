import 'package:flutter/material.dart';

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
      child:const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Profile Manager',
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
