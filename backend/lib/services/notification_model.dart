// lib/services/notification_model.dart

enum NotificationType {
  unlockedGameScenario,
  klaroAlert,
  paymentReminder,
  promotionalOffer,
  balanceWarning,
  welcome,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;
  final String? scenarioName; // NEW: Scenario name for scenario-based notifications

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.scenarioName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'scenarioName': scenarioName,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      type: NotificationType.values[map['type']],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'],
      scenarioName: map['scenarioName'],
    );
  }
}
