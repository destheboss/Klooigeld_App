// lib/features/scenarios/models/scenario_step.dart
import 'scenario_choice.dart';

class ScenarioStep {
  final String npcName;
  final String npcMessage;
  final List<ScenarioChoice> choices;

  ScenarioStep({
    required this.npcName,
    required this.npcMessage,
    required this.choices,
  });
}
