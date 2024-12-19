// NEW FILE: lib/components/widgets/account/avatar_upload_widget.dart
// This widget encapsulates the avatar upload logic. It shows the current avatar (if any) or a placeholder.
// When tapped, it calls a callback to pick a new image. This mirrors the introduction screen's avatar logic.

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AvatarUploadWidget extends StatelessWidget {
  final File? avatarFile;
  final VoidCallback onTap;

  const AvatarUploadWidget({
    Key? key,
    required this.avatarFile,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Similar style as introduction screen
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (avatarFile == null)
              Image.asset(
                'assets/images/introduction_screen/upload_avatar.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              )
            else
              ClipOval(
                child: Image.file(
                  avatarFile!,
                  width: 135,
                  height: 135,
                  fit: BoxFit.cover,
                ),
              ),
            // Overlay mask (if desired, can mirror introduction screen mask)
          ],
        ),
      ),
    );
  }
}
