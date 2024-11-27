import 'package:flutter/material.dart';
class StopWidget extends StatelessWidget {
  final IconData icon;
  final String status;
  final bool isActive;
  final Color color;

  StopWidget({
    required this.icon,
    required this.status,
    required this.isActive,
    required this.color,
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
                    content: Text(
                      "Great job! You've reached an unlocked stop.",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: color,
                  ),
                );
              }
            : null,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: isActive ? color : Colors.white.withOpacity(0.8),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.black.withOpacity(0.6),
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}