// lib/services/notification_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_model.dart';

class NotificationService extends ChangeNotifier {
  static const String _prefsKey = 'app_notifications';
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  bool get hasUnreadNotifications => _notifications.any((notif) => !notif.isRead);

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
    notifyListeners();
  }

  // Save notifications to SharedPreferences
  Future<void> _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawList = _notifications.map((notif) => jsonEncode(notif.toMap())).toList();
    await prefs.setStringList(_prefsKey, rawList);
  }

  // Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
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
      AppNotification(
        id: '1',
        title: 'Unlocked Game Scenario',
        message: 'You have unlocked a new game scenario!',
        type: NotificationType.unlockedGameScenario,
        timestamp: DateTime.now(),
      ),
    );
    await addNotification(
      AppNotification(
        id: '2',
        title: 'BNPL Alert',
        message: 'You have a new Buy Now, Pay Later option available.',
        type: NotificationType.bnplAlert,
        timestamp: DateTime.now(),
      ),
    );
    await addNotification(
      AppNotification(
        id: '3',
        title: 'Payment Reminder',
        message: 'Your payment is pending. Please complete it.',
        type: NotificationType.paymentReminder,
        timestamp: DateTime.now(),
      ),
    );
    // Add more mock notifications as needed
  }
}
