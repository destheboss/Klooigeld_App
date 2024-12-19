// Below is the updated AccountCard widget to place the icon at the right end, and have
// the title, input, and icon all on one row.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../theme/app_theme.dart';

class AccountCard extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final IconData icon;
  final Widget child;
  final bool iconOnRight;

  const AccountCard({
    Key? key,
    required this.title,
    required this.backgroundColor,
    required this.icon,
    required this.child,
    this.iconOnRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Row: [Title & Child] ... [Icon]
    // Title and child arranged horizontally as well.
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: iconOnRight
            ? [
                // Title & Child on left
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: AppTheme.titleFont,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            child,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FaIcon(icon, size: 24, color: AppTheme.white),
              ]
            : [
                FaIcon(icon, size: 30, color: AppTheme.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: AppTheme.titleFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      child,
                    ],
                  ),
                ),
              ],
      ),
    );
  }
}
