import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/notification_service.dart';
import '../../../services/notification_model.dart';
import '../../../theme/app_theme.dart';
import 'notification_card.dart';
import '../../../../screens/(learning_road)/learning-road_screen.dart'; // Import to navigate

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
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to update timestamps
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + 100,
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
          Container(
            color: Colors.transparent,
          ),
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
                      Consumer<NotificationService>(
                        builder: (context, notificationService, child) {
                          List<AppNotification> notifications = notificationService.notifications;

                          if (notifications.isEmpty) {
                            return Container(
                              height: 150,
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

                          double cardHeight = 95.0;
                          int visibleCount = notifications.length > 3 ? 3 : notifications.length;
                          double dropdownHeight = visibleCount * cardHeight + 16;
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
                                      },
                                      child: GestureDetector(
                                        onTap: () async {
                                          await notificationService.markAsRead(notif.id);
                                          // Navigate if this is an Unlocked Game Scenario notification
                                          if (notif.type == NotificationType.unlockedGameScenario) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const LearningRoadScreen()),
                                            );
                                          }
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
        return AppTheme.klooigeldPaars;
      default:
        return AppTheme.klooigeldBlauw;
    }
  }
}
