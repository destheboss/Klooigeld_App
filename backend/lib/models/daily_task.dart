// lib/models/daily_task.dart

import 'package:flutter/material.dart';

enum LinkedScreen {
  tips,
  learningRoad,
  rewardsShop,
}

// 1) Add a new enum for your task icons:
enum DailyTaskIcon {
  lightbulb,
  gamepad,
  unlock,
  shoppingBag,
}

class DailyTask {
  final String id;
  final String title;
  final String description;

  // 2) Remove final IconData icon; and add:
  final DailyTaskIcon dailyTaskIcon;

  final LinkedScreen linkedScreen;
  final int klooicashReward;
  bool isCompleted;

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    // 3) Replace icon with dailyTaskIcon in the constructor
    required this.dailyTaskIcon,
    required this.linkedScreen,
    required this.klooicashReward,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,

        // 4) Store the dailyTaskIcon as a String
        'dailyTaskIcon': dailyTaskIcon.name,

        'linkedScreen': linkedScreen.index,
        'klooicashReward': klooicashReward,
        'isCompleted': isCompleted,
      };

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],

      // 5) Recreate the enum from the stored string
      dailyTaskIcon: DailyTaskIcon.values.firstWhere(
        (icon) => icon.name == json['dailyTaskIcon'],
      ),

      linkedScreen: LinkedScreen.values[json['linkedScreen']],
      klooicashReward: json['klooicashReward'],
      isCompleted: json['isCompleted'],
    );
  }
}
