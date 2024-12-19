// lib/components/widgets/daily_tasks/daily_task_overlay.dart

import 'package:backend/screens/(learning_road)/learning-road_screen.dart';
import 'package:backend/screens/(rewards)/rewards_shop_screen.dart';
import 'package:backend/screens/(tips)/tips_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/daily_task.dart';
import '../../../services/daily_task_service.dart';
import '../../../theme/app_theme.dart';
import 'daily_task_card.dart';

class DailyTaskOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const DailyTaskOverlay({super.key, required this.onClose});

  void _navigateToTask(BuildContext context, DailyTask task) async {
    if (task.isCompleted) {
      // Show SnackBar alert for already completed task
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
    } else {
      // Navigate to the linked screen based on the task
      switch (task.linkedScreen) {
        case LinkedScreen.tips:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TipsScreen()),
          );
          break;
        case LinkedScreen.learningRoad:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LearningRoadScreen()),
          );
          break;
        case LinkedScreen.rewardsShop:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RewardsShopScreen()),
          );
          break;
      }
      // Mark the task as completed after navigation
      Provider.of<DailyTaskService>(context, listen: false)
          .markTaskAsCompleted(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Material(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.black, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16.0),
                child: Consumer<DailyTaskService>(
                  builder: (context, taskService, child) {
                    final tasks = taskService.tasks;
                    final allTasksCompleted =
                        tasks.every((task) => task.isCompleted);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.list,
                                  color: AppTheme.black,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Daily Tasks',
                                  style: TextStyle(
                                    fontFamily: AppTheme.titleFont,
                                    fontSize: 24,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: onClose,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppTheme.black, width: 1.8),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 19,
                                  color: AppTheme.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                        if (allTasksCompleted)
                          Column(
                            children: [
                              const Icon(
                                FontAwesomeIcons.faceGrinSquint,
                                size: 48,
                                color: AppTheme.nearlyBlack2,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Check back for more tomorrow!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTheme.neighbor,
                                  fontSize: 16,
                                  color: AppTheme.black,
                                ),
                              ),
                              const SizedBox(height: 25),
                            ],
                          )
                        else
                          Column(
                            children: tasks.map((task) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: DailyTaskCard(
                                  task: task,
                                  onTap: () => _navigateToTask(context, task),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
