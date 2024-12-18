// lib/components/widgets/notifications/notification_dropdown.dart

// Changes:
// - Replaced the AlertDialog with CustomDialog for payment confirmation
// - Renamed Klaro Payment ... strings to Klaro ... strings in notifications
// - If not enough balance, update the transaction amount by adding interest instead of adding a separate interest transaction
// - Show bottom alert using the same styling approach as the shop's "already purchased" alert
// - After successful payment, update klooicash and then show bottom alert
// - Add a callback `onKlooicashUpdated` that, when triggered, forces HomeScreen to refresh by calling _refreshData()
//   For simplicity, we can pass a callback from HomeScreen to NotificationDropdown. If not originally provided, add it now.

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
import '../../../main.dart'; // For routeObserver if needed
import '../../../features/scenarios/widgets/custom_dialog.dart';

class NotificationDropdown extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onKlooicashUpdated; // NEW: callback to refresh home screen klooicash

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
    // Show a bottom alert styled similarly to "Item already purchased"
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

  // NEW: Handle Klaro Payment Attempt using CustomDialog
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

  final cost = tx.amount.abs(); // e.g., 700K
  // Show CustomDialog for payment confirmation
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
                backgroundColor: AppTheme.klooigeldRozeAlt, // Changed to klooigeldGreen
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
                backgroundColor: AppTheme.klooigeldGroen, // Changed to klooigeldGreen
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
    borderColor: AppTheme.klooigeldGroen,       // Set border color to klooigeldGreen
    iconColor: AppTheme.klooigeldGroen,         // Set icon color to klooigeldGreen
    closeButtonColor: AppTheme.klooigeldGroen,  // Set close button color to klooigeldGreen
  ),
);

  if (payNow == true) {
    if (currentBalance >= cost) {
      // Sufficient funds, pay it off
      final newBalance = currentBalance - cost;
      await _setCurrentKlooicash(newBalance);
      await TransactionService.payKlaroTransaction(transactionDescription);

      // Mark notification read and remove it (since it's paid)
      await notificationService.markAsRead(notif.id);
      await notificationService.deleteNotification(notif.id);

      // Refresh home screen balance
      widget.onKlooicashUpdated();

      // Show bottom alert for success
      _showBottomAlert("Payment successful!");
    } else {
      // Insufficient funds, add interest (e.g., 10% interest)
      // New amount = cost * 1.1
      final newCost = (cost * 1.1).round();
      final difference = newCost - cost;

      // Update the existing pending transaction with the new amount
      final updatedTx = TransactionRecord(
        description: tx.description,
        amount: -newCost, // keep negative since it's a debt
        date: tx.date,
      );

      await TransactionService.updateTransaction(tx, updatedTx);

      // Mark old notification as read
      await notificationService.markAsRead(notif.id);

      // Add a Klaro Failed notification
      await notificationService.addKlaroInterestNotification(updatedTx);

      // Show bottom alert for failure
      _showBottomAlert("Not enough funds! Debt increased by ${difference}K");

      // No immediate refresh of klooicash needed here since no payment was made
    }
  } else {
    // User canceled, do nothing
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
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
                                          if (notif.type == NotificationType.unlockedGameScenario) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const LearningRoadScreen()),
                                            );
                                          } else if (notif.type == NotificationType.klaroAlert && notif.transactionDescription != null) {
                                            // Handle Klaro payment attempt
                                            await _attemptKlaroPayment(notif.transactionDescription!, notificationService, notif);
                                          } 
                                          // Other notification types can be handled similarly if needed
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
