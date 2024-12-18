// lib/components/widgets/notifications/notification_card.dart

// Explanation of changes:
// Previously, we displayed the notification.message as plain text.
// For Balance Warning notifications, we now parse the message for balance values ending in 'K',
// and replace the 'K' with a currency image icon to match the shop's style.
// If the message ends with something like "250K", we split this into "250" and display a currency image
// after the number. If negative or no trailing 'K', we show the message as-is.

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
      iconColor = AppTheme.klooigeldRozeAlt;
    } else if (notification.type == NotificationType.welcome) {
      iconColor = AppTheme.klooigeldPaars;
    } else {
      iconColor = AppTheme.klooigeldBlauw;
    }

    // NEW: For Balance Warning messages, we replace 'K' with a currency image widget.
    // If the message ends with something like '250K', we'll show '250' + currency image.
    Widget messageWidget;
    if (notification.type == NotificationType.balanceWarning && notification.message.trim().endsWith('K')) {
      // Extract the numeric part before 'K'
      String trimmedMessage = notification.message.trim();
      String withoutK = trimmedMessage.substring(0, trimmedMessage.length - 1).trim();
      // Example: "Your balance dropped below 250K" -> we split and rebuild:
      // We'll split by space to find the numeric part easily
      // However, message might vary, so we carefully handle it:
      // We'll assume the last token before 'K' is the numeric value.
      final parts = withoutK.split(' ');
      final lastPart = parts.last;
      // Rebuild the message without the trailing numeric+K
      // Example: parts: ["Your", "balance", "dropped", "below", "250"]
      // lastPart: "250"
      // We'll remove the lastPart and show it separately with the currency icon
      String prefixMessage = parts.take(parts.length - 1).join(' ');
      messageWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              prefixMessage,
              style: TextStyle(
                fontFamily: AppTheme.neighbor,
                fontSize: 14,
                color: AppTheme.black.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            lastPart,
            style: TextStyle(
              fontFamily: AppTheme.neighbor,
              fontSize: 14,
              color: AppTheme.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(
            'assets/images/currency.png',
            width: 14,
            height: 14,
          ),
        ],
      );
    } else {
      // For all other notifications (including negative or no trailing K), show as-is.
      messageWidget = Text(
        notification.message,
        style: TextStyle(
          fontFamily: AppTheme.neighbor,
          fontSize: 14,
          color: AppTheme.black.withOpacity(0.8),
        ),
      );
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
                messageWidget, // REPLACED direct Text(notification.message) with widget logic above
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
