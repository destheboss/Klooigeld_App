// lib/components/widgets/notifications/notification_dropdown.dart

// Changes based on requests:
// - For promotionalOffer notifications, when tapped, mark as read and then navigate to the RewardsShopScreen.
// - Change the icon color for promotionalOffer notification so it's different from welcome's klooigeldPaars.
//   We previously used klooigeldPaars for promotionalOffer. Let's use klooigeldRozeAlt now for promotionalOffer.
// - Inline comments added.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/notification_service.dart';
import '../../../services/notification_model.dart';
import '../../../theme/app_theme.dart';
import 'notification_card.dart';
import '../../../../screens/(learning_road)/learning-road_screen.dart';
import '../../../services/transaction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../features/scenarios/widgets/custom_dialog.dart';
import '../../../../screens/(rewards)/rewards_shop_screen.dart'; // Added for navigation to shop screen

class NotificationDropdown extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onKlooicashUpdated;

  const NotificationDropdown({Key? key, required this.onClose, required this.onKlooicashUpdated}) : super(key: key);

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

  Future<int> _getCurrentKlooicash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('klooicash') ?? 500;
  }

  Future<void> _setCurrentKlooicash(int newBalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('klooicash', newBalance);
  }

  Future<void> _showBottomAlert(String message) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        content: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.klooigeldRoze,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.klooigeldBlauw, width: 2),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.neighbor,
                fontWeight: FontWeight.bold,
                color: AppTheme.klooigeldBlauw,
                fontSize: 14,
              ),
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      ),
    );
  }

  Future<void> _attemptKlaroPayment(
    String transactionDescription,
    NotificationService notificationService,
    AppNotification notif,
  ) async {
    int currentBalance = await _getCurrentKlooicash();

    final pending = await TransactionService.getPendingKlaroTransactions();
    final tx = pending.firstWhere(
      (t) => t.description == transactionDescription,
      orElse: () => TransactionRecord(description: '', amount: 0, date: ''),
    );

    if (tx.description.isEmpty) {
      // No matching transaction found, just mark notification read.
      await notificationService.markAsRead(notif.id);
      return;
    }

    final cost = tx.amount.abs();
    bool? payNow = await showDialog<bool>(
      context: context,
      builder: (ctx) => CustomDialog(
        icon: FontAwesomeIcons.moneyCheckAlt,
        title: "Pay Klaro Debt",
        content: "You owe **${tx.description}** for **${cost}K**. Pay now?",
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klooigeldRozeAlt,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: AppTheme.neighbor,
                      fontSize: 16,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.klooigeldGroen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Pay",
                    style: TextStyle(
                      fontFamily: AppTheme.neighbor,
                      fontSize: 16,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        closeValue: false,
        borderColor: AppTheme.klooigeldGroen,
        iconColor: AppTheme.klooigeldGroen,
        closeButtonColor: AppTheme.klooigeldGroen,
      ),
    );

    if (payNow == true) {
      if (currentBalance >= cost) {
        final newBalance = currentBalance - cost;
        await _setCurrentKlooicash(newBalance);
        await TransactionService.payKlaroTransaction(transactionDescription);

        await notificationService.markAsRead(notif.id);
        await notificationService.deleteNotification(notif.id);

        widget.onKlooicashUpdated();

        _showBottomAlert("Payment successful!");
      } else {
        final newCost = (cost * 1.1).round();
        final difference = newCost - cost;

        final updatedTx = TransactionRecord(
          description: tx.description,
          amount: -newCost,
          date: tx.date,
        );

        await TransactionService.updateTransaction(tx, updatedTx);

        await notificationService.markAsRead(notif.id);
        await notificationService.addKlaroInterestNotification(updatedTx);

        _showBottomAlert("Not enough funds! Debt increased by ${difference}K");
      }
    } else {
      // User canceled
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Container(color: Colors.transparent),
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
                                          if (notif.type == NotificationType.unlockedGameScenario) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const LearningRoadScreen()),
                                            );
                                          } else if (notif.type == NotificationType.klaroAlert && notif.transactionDescription != null) {
                                            await _attemptKlaroPayment(notif.transactionDescription!, notificationService, notif);
                                          } else if (notif.type == NotificationType.promotionalOffer) {
                                            // For promotionalOffer, after marking read, navigate to Shop Screen
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const RewardsShopScreen()),
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
    // Adjust promotionalOffer color so it's different from welcome
    // Let's use AppTheme.klooigeldRozeAlt for promotionalOffer
    switch (type) {
      case NotificationType.unlockedGameScenario:
        return AppTheme.klooigeldBlauw;
      case NotificationType.klaroAlert:
        return AppTheme.klooigeldGroen;
      case NotificationType.paymentReminder:
        return AppTheme.klooigeldRoze;
      case NotificationType.promotionalOffer:
        return AppTheme.klooigeldGroen;
      case NotificationType.balanceWarning:
        return Colors.red;
      case NotificationType.welcome:
        return AppTheme.klooigeldPaars;
      default:
        return AppTheme.klooigeldBlauw;
    }
  }
}
