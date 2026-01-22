import 'package:flutter/material.dart';
import '../../../../viewmodel/auth_viewmodel.dart';

class RegisterProfileAvatar extends StatelessWidget {
  final AuthViewModel authVM;

  const RegisterProfileAvatar({
    super.key,
    required this.authVM,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: colorScheme.onSurface.withOpacity(0.1),
          backgroundImage: authVM.profileImage != null
              ? FileImage(authVM.profileImage!)
              : null,
          child: authVM.profileImage == null
              ? Icon(
                  Icons.person,
                  size: 55,
                  color: colorScheme.onSurface.withOpacity(0.6),
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: authVM.pickImage,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.camera_alt,
                size: 18,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
