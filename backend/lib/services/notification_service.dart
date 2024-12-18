// lib/services/notification_service.dart

// Explanation of changes:
// - After adding the welcome notification on first launch, we now also add a promotional offer notification.
// - This promotional offer notification will appear only once, right after the welcome notification.
// - We store a boolean in SharedPreferences indicating that the promotional offer has been shown,
//   so it won't be shown again on subsequent launches.
// - The promotional offer applies discounts to certain shop items (shoes).
// - This integration ensures that when the user enters the shop screen,
//   they can see discounted prices for items in the "shoes" category.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';
import 'package:uuid/uuid.dart';
import 'transaction_service.dart';

class NotificationService extends ChangeNotifier {
  static const String _prefsKey = 'app_notifications';
  static const String _firstTimeKey = 'is_first_time';
  static const String _promoOfferKey = 'promo_offer_shown'; // NEW: track if promo offer shown
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

    if (isFirstTime) {
      // Add welcome notification
      await addWelcomeNotification();
      await prefs.setBool(_firstTimeKey, false);

      // Immediately after welcome, add the promotional offer notification if not already shown
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

  // NEW: Add Promotional Offer Notification after the welcome notification.
  Future<void> addPromotionalOfferNotification() async {
    await addNotification(
      title: 'Special Promotional Offer!',
      message: 'Limited-time discounts on all shoes! Visit the shop now.',
      type: NotificationType.promotionalOffer,
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

  /// Public method to re-check Klaro alerts, if needed
  Future<void> refreshKlaroAlerts() async {
    await _checkPendingKlaroTransactions();
    await _saveNotifications();
    notifyListeners();
  }
}
