// lib/components/widgets/notifications/notification_dropdown.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/notification_service.dart';
import '../../../services/notification_model.dart';
import '../../../theme/app_theme.dart';
import 'notification_card.dart';

class NotificationDropdown extends StatefulWidget {
  final VoidCallback onClose;

  const NotificationDropdown({Key? key, required this.onClose}) : super(key: key);

  @override
  _NotificationDropdownState createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<NotificationDropdown> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer that triggers every 3 seconds to update timestamps
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Trigger a rebuild to update timestamps
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + 100, // Scroll down by 100 pixels
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose, // Close when tapping outside
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Transparent overlay
          Container(
            color: Colors.transparent,
          ),
          // Notification container
          Positioned(
            right: 20,
            top: 60,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with "Notifications" and "Clear" text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Consumer<NotificationService>(
                          builder: (context, notificationService, child) {
                            return Row(
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
                                if (notificationService.notifications.length > 1)
                                  GestureDetector(
                                    onTap: () async {
                                      await notificationService.deleteAllNotifications();
                                      // Optionally, you can add a confirmation message here
                                    },
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(
                                        fontFamily: AppTheme.neighbor,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Notification List or "No Notifications" Message
                      Consumer<NotificationService>(
                        builder: (context, notificationService, child) {
                          List<AppNotification> notifications = notificationService.notifications;

                          if (notifications.isEmpty) {
                            return Container(
                              height: 150, // Fixed height for "No Notifications"
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/icons/email.png',
                                    width: 60,
                                    height: 60,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'No Notifications',
                                    style: TextStyle(
                                      fontFamily: AppTheme.neighbor,
                                      fontSize: 16,
                                      color: AppTheme.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          // Calculate dynamic height: each NotificationCard is approx 90 height
                          double cardHeight = 95.0;
                          int visibleCount = notifications.length > 3 ? 3 : notifications.length;
                          double dropdownHeight = visibleCount * cardHeight + 16; // padding

                          bool hasMore = notifications.length > 3;

                          return Column(
                            children: [
                              SizedBox(
                                height: dropdownHeight,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: notifications.length,
                                  itemBuilder: (context, index) {
                                    final notif = notifications[index];
                                    return Dismissible(
                                      key: Key(notif.id),
                                      direction: DismissDirection.horizontal,
                                      background: Container(
                                        color: _getBackgroundColor(notif.type),
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.only(left: 20),
                                        child: const FaIcon(
                                          FontAwesomeIcons.trash,
                                          color: Colors.white,
                                        ),
                                      ),
                                      secondaryBackground: Container(
                                        color: _getBackgroundColor(notif.type),
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 20),
                                        child: const FaIcon(
                                          FontAwesomeIcons.trash,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onDismissed: (direction) {
                                        notificationService.deleteNotification(notif.id);
                                        // Removed snackbar
                                      },
                                      child: GestureDetector(
                                        onTap: () async {
                                          await notificationService.markAsRead(notif.id);
                                          // Optionally, navigate to relevant screen based on notification type
                                          // For now, just mark as read
                                        },
                                        child: NotificationCard(notification: notif),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (hasMore)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GestureDetector(
                                    onTap: _scrollDown,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppTheme.nearlyBlack2,
                                      child: const FaIcon(
                                        FontAwesomeIcons.chevronDown,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get background color based on notification type
  Color _getBackgroundColor(NotificationType type) {
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
}
