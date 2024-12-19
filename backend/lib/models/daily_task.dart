// lib/models/daily_task.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum LinkedScreen {
  tips,
  learningRoad,
  rewardsShop,
}

class DailyTask {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final LinkedScreen linkedScreen;
  final int klooicashReward;
  bool isCompleted;

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.linkedScreen,
    required this.klooicashReward,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
        'linkedScreen': linkedScreen.index,
        'klooicashReward': klooicashReward,
        'isCompleted': isCompleted,
      };

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: IconData(json['icon'], fontFamily: json['fontFamily'], fontPackage: json['fontPackage']),
      linkedScreen: LinkedScreen.values[json['linkedScreen']],
      klooicashReward: json['klooicashReward'],
      isCompleted: json['isCompleted'],
    );
  }
}
