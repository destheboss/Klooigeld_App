// lib/services/notification_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationService extends ChangeNotifier {
  static const String _prefsKey = 'app_notifications';
  static const String _firstTimeKey = 'is_first_time';
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  bool get hasUnreadNotifications => _notifications.any((notif) => !notif.isRead);

  final Uuid _uuid = Uuid();

  NotificationService() {
    _loadNotifications();
  }

  // Load notifications from SharedPreferences
  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList(_prefsKey) ?? [];
    _notifications = rawList.map((e) {
      Map<String, dynamic> map = jsonDecode(e);
      return AppNotification.fromMap(map);
    }).toList();

    // Check if it's the first time the user is opening the app
    bool isFirstTime = prefs.getBool(_firstTimeKey) ?? true;
    if (isFirstTime) {
      await addWelcomeNotification();
      await prefs.setBool(_firstTimeKey, false);
    }

    notifyListeners();
  }

  // Save notifications to SharedPreferences
  Future<void> _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawList = _notifications.map((notif) => jsonEncode(notif.toMap())).toList();
    await prefs.setStringList(_prefsKey, rawList);
  }

  // Helper method to check if a notification is a welcome notification
  bool isWelcomeNotification(AppNotification notification) {
    return notification.type == NotificationType.welcome;
  }

  // Add a new notification with auto-generated ID and timestamp
  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final notification = AppNotification(
      id: _uuid.v4(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );

    // Check if the first notification is a welcome notification
    if (_notifications.isNotEmpty && isWelcomeNotification(_notifications.first)) {
      // Insert after the welcome notification
      _notifications.insert(1, notification);
    } else {
      // Insert at the beginning
      _notifications.insert(0, notification);
    }

    await _saveNotifications();
    notifyListeners();
  }

  // Add welcome notification for first-time users
  Future<void> addWelcomeNotification() async {
    final welcomeNotification = AppNotification(
      id: _uuid.v4(),
      title: 'Welcome to Klooigeld!',
      message: 'Thank you for joining us. Enjoy your experience!',
      type: NotificationType.welcome, // Updated to welcome type
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, welcomeNotification);
    await _saveNotifications();
    notifyListeners();
  }

  // Mark a notification as read
  Future<void> markAsRead(String id) async {
    int index = _notifications.indexWhere((notif) => notif.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Mark all notifications as read
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

  // Delete a single notification
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((notif) => notif.id == id);
    await _saveNotifications();
    notifyListeners();
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    _notifications.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }

  // Mock notifications for demonstration purposes
  Future<void> mockNotifications() async {
    await addNotification(
      title: 'Unlocked Game Scenario',
      message: 'You have unlocked a new game scenario!',
      type: NotificationType.unlockedGameScenario,
    );
    await addNotification(
      title: 'Klaro Alert',
      message: 'You have a new Klaro option available.',
      type: NotificationType.klaroAlert,
    );
    await addNotification(
      title: 'Payment Reminder',
      message: 'Your payment is pending. Please complete it.',
      type: NotificationType.paymentReminder,
    );
    // Add more mock notifications as needed
  }
}
