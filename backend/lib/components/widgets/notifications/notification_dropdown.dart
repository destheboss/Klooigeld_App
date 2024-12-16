// lib/components/widgets/notifications/notification_dropdown.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/notification_service.dart';
import '../../../services/notification_model.dart';
import '../../../theme/app_theme.dart';
import 'notification_card.dart';

class NotificationDropdown extends StatelessWidget {
  final VoidCallback onClose;

  const NotificationDropdown({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        List<AppNotification> notifications = notificationService.notifications;

        return Positioned(
          right: 20,
          top: 60,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with "Notifications" and "Clear All"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFont,
                            fontSize: 18,
                            color: AppTheme.nearlyBlack2,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await notificationService.deleteAllNotifications();
                            onClose();
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // List of notifications
                  SizedBox(
                    height: 300,
                    child: notifications.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No notifications'),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: notifications.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              return GestureDetector(
                                onTap: () async {
                                  await notificationService.markAsRead(notif.id);
                                  // Optionally, navigate to relevant screen based on notification type
                                  // For now, just close the dropdown
                                  onClose();
                                },
                                child: NotificationCard(notification: notif),
                              );
                            },
                          ),
                  ),
                  // Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onClose,
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
