// lib/components/widgets/notifications/notification_card.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/notification_model.dart';
import '../../../theme/app_theme.dart';

// We replicate the scenario order and colors from the learning road.
final List<String> scenarioNames = [
  "Buy Now, Pay Later",
  "Saving",
  "Gambling Basics",
  "Insurances",
  "Loans",
  "Investing",
];

final List<Color> unlockedStopColors = [
  Color(0xFFF787D9), // klooigeldRoze
  Color(0xFF1D1999), // klooigeldBlauw
  Color(0xFF99cf2d),
  Color(0xFFC8BBF3), // klooigeldPaars
];

// Helper to get the color for a given scenario name:
Color _getScenarioColor(String scenarioName) {
  int index = scenarioNames.indexOf(scenarioName);
  if (index == -1) {
    // default color if scenario not found
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

    // If scenarioName is available and type is unlockedGameScenario, use that scenario's color.
    // Otherwise, fall back to original logic.
    Color iconColor;
    if (notification.type == NotificationType.unlockedGameScenario && notification.scenarioName != null) {
      iconColor = _getScenarioColor(notification.scenarioName!);
    } else if (notification.type == NotificationType.klaroAlert) {
      iconColor = AppTheme.klooigeldGroen;
    } else if (notification.type == NotificationType.paymentReminder) {
      iconColor = AppTheme.klooigeldRoze;
    } else if (notification.type == NotificationType.promotionalOffer) {
      iconColor = AppTheme.klooigeldPaars;
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
          // Icon or "K" Text
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
