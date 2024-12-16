// lib/components/widgets/notifications/notification_card.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/notification_model.dart';
import '../../../theme/app_theme.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const NotificationCard({Key? key, required this.notification}) : super(key: key);

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.unlockedGameScenario:
        return FontAwesomeIcons.gamepad;
      case NotificationType.klaroAlert:
        return FontAwesomeIcons.creditCard;
      case NotificationType.paymentReminder:
        return FontAwesomeIcons.wallet;
      case NotificationType.promotionalOffer:
        return FontAwesomeIcons.tag;
      case NotificationType.balanceWarning:
        return FontAwesomeIcons.exclamationTriangle;
      case NotificationType.welcome:
        return Icons.circle; // Placeholder, will be replaced with "K"
      default:
        return FontAwesomeIcons.solidBell;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.unlockedGameScenario:
        return AppTheme.klooigeldBlauw;
      case NotificationType.klaroAlert:
        return AppTheme.klooigeldGroen;
      case NotificationType.paymentReminder:
        return AppTheme.klooigeldRoze;
      case NotificationType.promotionalOffer:
        return AppTheme.klooigeldPaars;
      case NotificationType.balanceWarning:
        return Colors.red;
      case NotificationType.welcome:
        return AppTheme.klooigeldPaars; // Assign a suitable color for welcome
      default:
        return AppTheme.klooigeldBlauw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWelcome = notification.type == NotificationType.welcome;
    final iconColor = _getIconColor(notification.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon or "K" Text
          SizedBox(
            width: 24, // Fixed width for icon area
            height: 24, // Fixed height for icon area
            child: isWelcome
                ? Text(
                    'K',
                    style: TextStyle(
                      fontFamily: AppTheme.logoFont1, // Use the AppTheme.logo font style
                      fontSize: 24, // Same size as icons
                      color: iconColor,
                    ),
                    textAlign: TextAlign.center,
                  )
                : FaIcon(
                    _getIcon(notification.type),
                    color: iconColor,
                    size: 24, // Consistent size
                  ),
          ),
          const SizedBox(width: 12),
          // Notification details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  notification.title,
                  style: TextStyle(
                    fontFamily: AppTheme.titleFont,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.nearlyBlack2,
                  ),
                ),
                const SizedBox(height: 4),
                // Message
                Text(
                  notification.message,
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontSize: 14,
                    color: AppTheme.black.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                // Timestamp
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontSize: 12,
                    color: AppTheme.deactivatedText,
                  ),
                ),
              ],
            ),
          ),
          // Unread badge on the right end
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
