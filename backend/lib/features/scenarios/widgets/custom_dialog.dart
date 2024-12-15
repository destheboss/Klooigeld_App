// lib/features/scenarios/widgets/custom_dialog.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:backend/theme/app_theme.dart';

class CustomDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final List<Widget> actions;
  final dynamic closeValue;
  final MainAxisAlignment actionsAlignment;

  const CustomDialog({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
    required this.actions,
    this.closeValue,
    this.actionsAlignment = MainAxisAlignment.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.klooigeldBlauw, width: 2),
      ),
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, closeValue);
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(icon, color: AppTheme.klooigeldBlauw, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTheme.neighbor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, closeValue),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.klooigeldBlauw, width: 1.8),
                      ),
                      child: const Icon(Icons.close, size: 16, color: AppTheme.klooigeldBlauw),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Content
              Text(
                content,
                style: TextStyle(
                  fontFamily: AppTheme.neighbor,
                  fontSize: 16,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: actionsAlignment,
                children: actions.map((action) => Flexible(child: action)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
