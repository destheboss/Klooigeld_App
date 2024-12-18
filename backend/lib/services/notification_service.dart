// lib/services/notification_service.dart

// Explanation of changes:
// The previous implementation sometimes sent multiple notifications for the lower thresholds (below 50 or negative)
// after having already sent a notification for the higher threshold (below 250).
//
// Adjustments made:
// 1. Before sending a notification, we now set the corresponding sent-flag in SharedPreferences first. This ensures
//    that even if checkBalanceWarnings is called again rapidly, it will not resend the same notification.
// 2. The logic is strictly sequential. We first check negative, then below 50, then below 250. Only one condition can pass.
// 3. After sending a new notification, we do not reset flags until the balance recovers above that threshold. This prevents
//    re-triggering the same alert multiple times without recovery.
//
// Result:
// Only one notification is sent at a time, and no double notifications are sent if user continuously drops balance.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';
import 'package:uuid/uuid.dart';
import 'transaction_service.dart';

class NotificationService extends ChangeNotifier {
  static const String _prefsKey = 'app_notifications';
  static const String _firstTimeKey = 'is_first_time';
  static const String _promoOfferKey = 'promo_offer_shown';
  static const String _bnplNotiSentKey = 'bnpl_notification_sent';

  // Keys to track if balance warnings have been sent
  static const String _balanceBelow250SentKey = 'balance_below_250_sent';
  static const String _balanceBelow50SentKey = 'balance_below_50_sent';
  static const String _balanceNegativeSentKey = 'balance_negative_sent';

  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;
  bool get hasUnreadNotifications => _notifications.any((notif) => !notif.isRead);

  final Uuid _uuid = Uuid();

  NotificationService() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList(_prefsKey) ?? [];
    _notifications = rawList.map((e) {
      Map<String, dynamic> map = jsonDecode(e);
      return AppNotification.fromMap(map);
    }).toList();

    bool isFirstTime = prefs.getBool(_firstTimeKey) ?? true;
    bool promoOfferShown = prefs.getBool(_promoOfferKey) ?? false;
    bool bnplNotiSent = prefs.getBool(_bnplNotiSentKey) ?? false;

    // On first launch, show welcome and promo
    if (isFirstTime) {
      await addWelcomeNotification();
      await prefs.setBool(_firstTimeKey, false);

      if (!bnplNotiSent) {
        await addBNPLScenarioNotification();
        await prefs.setBool(_bnplNotiSentKey, true);
      }

      if (!promoOfferShown) {
        await addPromotionalOfferNotification();
        await prefs.setBool(_promoOfferKey, true);
      }
    }

    await _checkPendingKlaroTransactions();
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawList = _notifications.map((notif) => jsonEncode(notif.toMap())).toList();
    await prefs.setStringList(_prefsKey, rawList);
  }

  bool isWelcomeNotification(AppNotification notification) {
    return notification.type == NotificationType.welcome;
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? scenarioName,
    String? transactionDescription,
  }) async {
    final notification = AppNotification(
      id: _uuid.v4(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      scenarioName: scenarioName,
      transactionDescription: transactionDescription,
    );

    if (_notifications.isNotEmpty && isWelcomeNotification(_notifications.first)) {
      _notifications.insert(1, notification);
    } else {
      _notifications.insert(0, notification);
    }

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> addWelcomeNotification() async {
    final welcomeNotification = AppNotification(
      id: _uuid.v4(),
      title: 'Welcome to Klooigeld!',
      message: 'Thank you for joining us. Enjoy your experience!',
      type: NotificationType.welcome,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, welcomeNotification);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> addPromotionalOfferNotification() async {
    await addNotification(
      title: 'Special Promotional Offer!',
      message: 'Limited-time discounts on all shoes! Visit the shop now.',
      type: NotificationType.promotionalOffer,
    );
  }

  Future<void> addBNPLScenarioNotification() async {
    const scenarioName = "Buy Now, Pay Later";
    const scenarioMsg = "Time to flex those delayed payment skills!";
    await addNotification(
      title: 'Fresh Scenario Dropped!',
      message: "Congrats! You just unlocked '$scenarioName'. $scenarioMsg",
      type: NotificationType.unlockedGameScenario,
      scenarioName: scenarioName,
    );
  }

  Future<void> markAsRead(String id) async {
    int index = _notifications.indexWhere((notif) => notif.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    bool anyUnread = false;
    for (var notif in _notifications) {
      if (!notif.isRead) {
        notif.isRead = true;
        anyUnread = true;
      }
    }
    if (anyUnread) {
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((notif) => notif.id == id);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteAllNotifications() async {
    _notifications.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }

  Future<void> _checkPendingKlaroTransactions() async {
    final pendingKlaroTx = await TransactionService.getPendingKlaroTransactions();
    for (var tx in pendingKlaroTx) {
      bool exists = _notifications.any((n) =>
          n.type == NotificationType.klaroAlert &&
          n.transactionDescription == tx.description &&
          !n.isRead
      );
      if (!exists) {
        await addKlaroAlertNotification(tx);
      }
    }
  }

  Future<void> addKlaroAlertNotification(TransactionRecord tx) async {
    await addNotification(
      title: 'Klaro Reminder',
      message: 'You owe: ${tx.description}. Tap to pay now!',
      type: NotificationType.klaroAlert,
      transactionDescription: tx.description,
    );
  }

  Future<void> addKlaroInterestNotification(TransactionRecord tx) async {
    await addNotification(
      title: 'Klaro Payment Failed',
      message: 'Not enough funds. Your Klaro debt for ${tx.description} increased!',
      type: NotificationType.klaroAlert,
      transactionDescription: tx.description,
    );
  }

  Future<void> refreshKlaroAlerts() async {
    await _checkPendingKlaroTransactions();
    await _saveNotifications();
    notifyListeners();
  }

  // Revised checkBalanceWarnings to prevent multiple notifications:
  Future<void> checkBalanceWarnings(int currentBalance) async {
    final prefs = await SharedPreferences.getInstance();
    bool below250Sent = prefs.getBool(_balanceBelow250SentKey) ?? false;
    bool below50Sent = prefs.getBool(_balanceBelow50SentKey) ?? false;
    bool negativeSent = prefs.getBool(_balanceNegativeSentKey) ?? false;

    String? warningMessage;
    String warningTitle = 'Balance Warning';
    String triggeredThreshold = '';

    // Check thresholds in order of severity:
    if (currentBalance < 0 && !negativeSent) {
      warningMessage = "Your balance is negative!";
      triggeredThreshold = 'negative';
    } else if (currentBalance < 50 && !below50Sent && !negativeSent) {
      warningMessage = "Your balance dropped below 50K";
      triggeredThreshold = 'below50';
    } else if (currentBalance < 250 && !below250Sent && !below50Sent && !negativeSent) {
      warningMessage = "Your balance dropped below 250K";
      triggeredThreshold = 'below250';
    }

    // If we have a new warning to trigger:
    if (triggeredThreshold.isNotEmpty && warningMessage != null) {
      // Set the flag FIRST before adding notification
      if (triggeredThreshold == 'negative') {
        await prefs.setBool(_balanceNegativeSentKey, true);
      } else if (triggeredThreshold == 'below50') {
        await prefs.setBool(_balanceBelow50SentKey, true);
      } else if (triggeredThreshold == 'below250') {
        await prefs.setBool(_balanceBelow250SentKey, true);
      }

      await addNotification(
        title: warningTitle,
        message: warningMessage,
        type: NotificationType.balanceWarning,
      );
    }

    // Reset logic when user recovers above thresholds:
    if (currentBalance >= 250) {
      // Fully reset if above 250
      if (below250Sent || below50Sent || negativeSent || triggeredThreshold.isNotEmpty) {
        await prefs.setBool(_balanceBelow250SentKey, false);
        await prefs.setBool(_balanceBelow50SentKey, false);
        await prefs.setBool(_balanceNegativeSentKey, false);
      }
    } else if (currentBalance >= 50 && currentBalance < 250) {
      // Recovered above 50 but still below 250 resets lower alerts:
      if (below50Sent || negativeSent) {
        await prefs.setBool(_balanceBelow50SentKey, false);
        await prefs.setBool(_balanceNegativeSentKey, false);
      }
    } else if (currentBalance >= 0 && currentBalance < 50) {
      // Recovered above 0 but still below 50 resets negative alert:
      if (negativeSent) {
        await prefs.setBool(_balanceNegativeSentKey, false);
      }
    }

    notifyListeners();
  }
}
