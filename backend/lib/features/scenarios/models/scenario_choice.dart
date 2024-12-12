class ScenarioChoice {
  final String text;
  final double kChange;
  final String outcome;
  final String dialogueText; // New field for user's spoken line

  ScenarioChoice({
    required this.text,
    required this.kChange,
    required this.outcome,
    required this.dialogueText,
  });
}