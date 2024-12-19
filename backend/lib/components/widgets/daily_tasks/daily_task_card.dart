// lib/components/widgets/daily_tasks/daily_task_card.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../models/daily_task.dart';
import '../../../../theme/app_theme.dart';

class DailyTaskCard extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onTap;

  const DailyTaskCard({super.key, required this.task, required this.onTap});

  Color _getTaskColor() {
    switch (task.id) {
      case 'read_tip':
        return AppTheme.klooigeldPaars;
      case 'play_scenario':
        return AppTheme.klooigeldRozeAlt;
      case 'unlock_scenario':
        return AppTheme.klooigeldBlauw;
      case 'shop_item':
        return AppTheme.klooigeldGroen;
      default:
        return AppTheme.klooigeldRoze;
    }
  }

  // Method to show the styled SnackBar
  void _showTaskCompletedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove any existing SnackBars
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
            child: const Text(
              "Task already completed!",
              textAlign: TextAlign.center,
              style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    final taskColor = _getTaskColor();

    return GestureDetector(
      onTap: () {
        if (task.isCompleted) {
          // Show the styled SnackBar if the task is already completed
          _showTaskCompletedSnackBar(context);
        } else {
          // Invoke the onTap callback if the task is not completed
          onTap();
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: taskColor, width: 2),
        ),
        color: taskColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: FaIcon(
              task.icon,
              color: AppTheme.white,
              size: 24,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontFamily: AppTheme.titleFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,

            ),
          ),
          subtitle: Text(
            task.description,
            style: TextStyle(
              fontFamily: AppTheme.neighbor,
              fontSize: 14,
              color: AppTheme.white,

            ),
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.white,
                width: 2,
              ),
              color: task.isCompleted ? AppTheme.white : taskColor,
            ),
            child: task.isCompleted
                ? Icon(
                    Icons.check,
                    color: taskColor,
                    size: 16,
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    color: AppTheme.white,
                    size: 16,
                  ),
          ),
        ),
      ),
    );
  }
}
