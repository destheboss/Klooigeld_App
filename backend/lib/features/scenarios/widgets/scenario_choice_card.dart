// lib/features/scenarios/widgets/scenario_choice_card.dart
import 'package:flutter/material.dart';
import 'package:backend/theme/app_theme.dart';

class ScenarioChoiceCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ScenarioChoiceCard({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.klooigeldBlauw, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppTheme.neighbor,
            fontWeight: FontWeight.w600, // semi-bold for interactive elements
            fontSize: 14,
            color: AppTheme.klooigeldBlauw,
          ),
        ),
      ),
    );
  }
}
