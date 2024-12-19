// lib/utils/scenario_colors.dart

import 'package:flutter/material.dart';

// Define scenario names
final List<String> scenarioNames = [
  "Buy Now, Pay Later",
  "Saving",
  "Gambling Basics",
  "Insurances",
  "Loans",
  "Investing",
];

// Define corresponding colors for scenarios
final List<Color> unlockedStopColors = [
  Color(0xFFF787D9),
  Color(0xFF1D1999),
  Color(0xFF99cf2d),
  Color(0xFFC8BBF3),
  Color(0xFFFFA07A), // Added another color for more scenarios if needed
  Color(0xFF20B2AA),
];

/// Returns the color associated with a given scenario name.
/// Defaults to AppTheme.klooigeldBlauw if the scenario name is not found.
Color getScenarioColor(String? scenarioName) {
  if (scenarioName == null) {
    return Colors.blue; // Replace with AppTheme.klooigeldBlauw if accessible
  }
  int index = scenarioNames.indexOf(scenarioName);
  if (index == -1) {
    return Colors.blue; // Replace with AppTheme.klooigeldBlauw if accessible
  }
  return unlockedStopColors[index % unlockedStopColors.length];
}
