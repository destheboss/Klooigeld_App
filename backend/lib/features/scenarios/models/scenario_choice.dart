class ScenarioChoice {
  final String text;
  final int kChange;
  final String outcome;
  final String dialogueText; // New field for user's spoken line

  ScenarioChoice({
    required this.text,
    required this.kChange,
    required this.outcome,
    required this.dialogueText,
  });
}