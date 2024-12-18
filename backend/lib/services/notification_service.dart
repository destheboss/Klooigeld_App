// lib/services/notification_service.dart

// Explanation of changes:
// - After adding the promotional offer notification on the first launch, also add the BNPL unlock notification immediately.
// - Previously, BNPL scenario unlock notification was only sent after navigating to learning road or completing a scenario.
// - Now, on first launch, after adding the promotional offer notification, we check if BNPL scenario (index=0) is considered unlocked by default and send its notification if not already sent.
// - We use a SharedPreferences bool 'bnpl_notification_sent' to ensure it only appears once.

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
  static const String _bnplNotiSentKey = 'bnpl_notification_sent'; // NEW: track if BNPL notification sent
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

    // On first launch, show welcome + promotional offer notifications
    if (isFirstTime) {
      await addWelcomeNotification();
      await prefs.setBool(_firstTimeKey, false);

      // After promotional offer, also show BNPL scenario unlocked notification if not sent
      // BNPL is the first scenario and considered unlocked by default.
      // Only do this if bnpl_notification_sent is false.
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

  // NEW: Add BNPL scenario unlocked notification after promotional offer on first launch
  Future<void> addBNPLScenarioNotification() async {
    // BNPL scenario name is "Buy Now, Pay Later"
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
}
