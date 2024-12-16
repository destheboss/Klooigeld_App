// lib/components/widgets/notifications/notification_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/notification_model.dart';
import '../../../services/notification_service.dart';
import '../../../theme/app_theme.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const NotificationCard({Key? key, required this.notification}) : super(key: key);

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.unlockedGameScenario:
        return Icons.gamepad;
      case NotificationType.bnplAlert:
        return Icons.credit_card;
      case NotificationType.paymentReminder:
        return Icons.payment;
      case NotificationType.promotionalOffer:
        return Icons.local_offer;
      case NotificationType.balanceWarning:
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.unlockedGameScenario:
        return AppTheme.klooigeldBlauw;
      case NotificationType.bnplAlert:
        return AppTheme.klooigeldGroen;
      case NotificationType.paymentReminder:
        return AppTheme.klooigeldRoze;
      case NotificationType.promotionalOffer:
        return AppTheme.klooigeldPaars;
      case NotificationType.balanceWarning:
        return Colors.red;
      default:
        return AppTheme.klooigeldBlauw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: notification.isRead ? AppTheme.nearlyWhite : AppTheme.klooigeldGroen.withOpacity(0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIcon(notification.type),
            color: _getIconColor(notification.type),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: AppTheme.titleFont,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.nearlyBlack2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Provider.of<NotificationService>(context, listen: false)
                            .deleteNotification(notification.id);
                      },
                      child: const Icon(Icons.delete, size: 20, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontSize: 14,
                    color: AppTheme.darkText,
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
