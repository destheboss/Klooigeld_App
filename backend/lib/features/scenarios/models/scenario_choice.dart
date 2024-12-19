// lib/features/scenarios/models/scenario_choice.dart
class ScenarioChoice {
  final String text;
  final int kChange;
  final String outcome;
  final String dialogueText; // New field

  ScenarioChoice({
    required this.text,
    required this.kChange,
    required this.outcome,
    required this.dialogueText,
  });
}