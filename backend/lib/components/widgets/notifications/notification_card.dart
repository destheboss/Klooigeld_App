// lib/components/widgets/notifications/notification_card.dart

// No functional changes needed here besides ensuring Klaro alerts have meaningful icons/colors.
// The code remains as is. The card just displays notifications.
// Comments added for clarity.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/notification_model.dart';
import '../../../theme/app_theme.dart';

final List<String> scenarioNames = [
  "Buy Now, Pay Later",
  "Saving",
  "Gambling Basics",
  "Insurances",
  "Loans",
  "Investing",
];

final List<Color> unlockedStopColors = [
  Color(0xFFF787D9), 
  Color(0xFF1D1999), 
  Color(0xFF99cf2d),
  Color(0xFFC8BBF3), 
];

Color _getScenarioColor(String scenarioName) {
  int index = scenarioNames.indexOf(scenarioName);
  if (index == -1) {
    return AppTheme.klooigeldBlauw;
  }
  return unlockedStopColors[index % unlockedStopColors.length];
}

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
        return Icons.circle;
      default:
        return FontAwesomeIcons.solidBell;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWelcome = notification.type == NotificationType.welcome;

    Color iconColor;
    if (notification.type == NotificationType.unlockedGameScenario && notification.scenarioName != null) {
      iconColor = _getScenarioColor(notification.scenarioName!);
    } else if (notification.type == NotificationType.klaroAlert) {
      iconColor = AppTheme.klooigeldGroen;
    } else if (notification.type == NotificationType.paymentReminder) {
      iconColor = AppTheme.klooigeldRoze;
    } else if (notification.type == NotificationType.promotionalOffer) {
      iconColor = AppTheme.klooigeldGroen;
    } else if (notification.type == NotificationType.balanceWarning) {
      iconColor = Colors.red;
    } else if (notification.type == NotificationType.welcome) {
      iconColor = AppTheme.klooigeldPaars;
    } else {
      iconColor = AppTheme.klooigeldBlauw;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: isWelcome
                ? Text(
                    'K',
                    style: TextStyle(
                      fontFamily: AppTheme.logoFont1,
                      fontSize: 24,
                      color: iconColor,
                    ),
                    textAlign: TextAlign.center,
                  )
                : FaIcon(
                    _getIcon(notification.type),
                    color: iconColor,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  notification.message,
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontSize: 14,
                    color: AppTheme.black.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
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
