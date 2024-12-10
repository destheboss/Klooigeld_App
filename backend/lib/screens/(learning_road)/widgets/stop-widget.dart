import 'package:flutter/material.dart';

class StopWidget extends StatelessWidget {
  final IconData icon;
  final String status;
  final bool isActive;
  final bool isCurrent;
  final Color color;

  StopWidget({
    required this.icon,
    required this.status,
    required this.isActive,
    required this.isCurrent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isActive ? "Unlocked Stop" : "Locked Stop",        
<<<<<<< Updated upstream
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : Colors.white.withOpacity(0.8),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.5), // Lighter version of the color
                      blurRadius: 15, // Increase for a softer glow
                      spreadRadius: 8, // Size of the glow
                    ),
                  ]
                : [],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.black.withOpacity(0.6),
              size: 60,
            ),
=======
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? color : AppTheme.klooigeldBlauw.withOpacity(0.8),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 8,
                  ),
                ]
              : [],
        ),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.transparent,
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.9),
            size: 50,
>>>>>>> Stashed changes
          ),
        ),
      ),
    );
  }
}
