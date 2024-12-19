// NEW FILE: lib/components/widgets/account/account_section_toggle.dart
// This widget shows two toggle options: "Your Details" and "Leaderboard" in a Row, similar to 
// top sections in other screens. The selected section is highlighted.

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AccountSectionToggle extends StatelessWidget {
  final String leftTitle;
  final String rightTitle;
  final bool showLeft;
  final ValueChanged<bool> onToggle;

  const AccountSectionToggle({
    Key? key,
    required this.leftTitle,
    required this.rightTitle,
    required this.showLeft,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Two tappable texts; the selected one is bolder/darker.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onToggle(true),
          child: Text(
            leftTitle.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTheme.neighbor,
              fontSize: 16,
              fontWeight: showLeft ? FontWeight.bold : FontWeight.w400,
              color: showLeft ? AppTheme.nearlyBlack2 : AppTheme.grey,
            ),
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => onToggle(false),
          child: Text(
            rightTitle.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTheme.neighbor,
              fontSize: 16,
              fontWeight: !showLeft ? FontWeight.bold : FontWeight.w400,
              color: !showLeft ? AppTheme.nearlyBlack2 : AppTheme.grey,
            ),
          ),
        ),
      ],
    );
  }
}
