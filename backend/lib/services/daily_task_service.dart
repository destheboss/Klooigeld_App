// lib/services/daily_task_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_task.dart';
import 'transaction_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DailyTaskService extends ChangeNotifier {
  static const String dailyTasksKey = 'daily_tasks';
  static const String lastResetDateKey = 'last_reset_date';

  List<DailyTask> _tasks = [];

  List<DailyTask> get tasks => _tasks;

  DailyTaskService() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayDate = _getTodayDateString();
    String? lastResetDate = prefs.getString(lastResetDateKey);

    if (lastResetDate != todayDate) {
      // Reset tasks for a new day
      _initializeTasks();
      await prefs.setString(lastResetDateKey, todayDate);
      await _saveTasks();
    } else {
      // Load existing tasks
      List<String> rawTasks = prefs.getStringList(dailyTasksKey) ?? [];
      _tasks = rawTasks.map((e) => DailyTask.fromJson(jsonDecode(e))).toList();
    }
    notifyListeners();
  }

  void _initializeTasks() {
  _tasks = [
    DailyTask(
      id: 'read_tip',
      title: 'Read a tip!',
      description: 'Go to the tips screen and read a tip.',
      // Replace icon: FontAwesomeIcons.lightbulb with:
      dailyTaskIcon: DailyTaskIcon.lightbulb,
      linkedScreen: LinkedScreen.tips,
      klooicashReward: 50,
    ),
    DailyTask(
      id: 'play_scenario',
      title: 'Play a scenario!',
      description: 'Play a scenario in the learning road screen.',
      dailyTaskIcon: DailyTaskIcon.gamepad,
      linkedScreen: LinkedScreen.learningRoad,
      klooicashReward: 100,
    ),
    DailyTask(
      id: 'unlock_scenario',
      title: 'Unlock a new scenario!',
      description: 'Unlock a new scenario in the learning road screen.',
      dailyTaskIcon: DailyTaskIcon.unlock,
      linkedScreen: LinkedScreen.learningRoad,
      klooicashReward: 150,
    ),
    DailyTask(
      id: 'shop_item',
      title: 'Shop for an item!',
      description: 'Visit the reward shop screen and shop for an item.',
      dailyTaskIcon: DailyTaskIcon.shoppingBag,
      linkedScreen: LinkedScreen.rewardsShop,
      klooicashReward: 200,
    ),
  ];
}

  Future<void> markTaskAsCompleted(String taskId) async {
    int index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1 && !_tasks[index].isCompleted) {
      _tasks[index].isCompleted = true;
      await _saveTasks();
      await TransactionService.addKlooicash(_tasks[index].klooicashReward);
      
      // Notify listeners about the change
      notifyListeners();
    }
  }


  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> rawTasks = _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(dailyTasksKey, rawTasks);
  }

  int get completedTasksCount => _tasks.where((task) => task.isCompleted).length;

  int get totalTasksCount => _tasks.length;

  double get completionPercentage => totalTasksCount == 0 ? 0 : completedTasksCount / totalTasksCount;

  Future<void> resetTasks() async {
    _initializeTasks();
    await _saveTasks();
    notifyListeners();
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
