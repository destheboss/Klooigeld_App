import 'package:backend/screens/(learning_road)/learning-road_screen.dart';
import 'package:flutter/material.dart';

class StopWidget extends StatelessWidget {
  final IconData icon;
  final String status;
  final bool isActive;

  StopWidget({
    required this.icon,
    required this.status,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isActive ? "Unlocked Stop" : "Locked Stop",
      child: GestureDetector(
        onTap: isActive
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Great job! You've reached an unlocked stop."),
                  ),
                );
              }
            : null,
        child: CircleAvatar(
          radius: 40,
          backgroundColor: isActive
              ? LearningRoadScreen.unlockedColor
              : LearningRoadScreen.lockedColor,
          child: Icon(
            icon,
            color: LearningRoadScreen.iconColor,
            size: 50,
          ),
        ),
      ),
    );
  }
}