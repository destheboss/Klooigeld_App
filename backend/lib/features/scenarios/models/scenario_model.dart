// lib/features/scenarios/models/scenario_model.dart
import 'scenario_step.dart';

class ScenarioModel {
  final List<ScenarioStep> steps;
  ScenarioModel({required this.steps});
  int get length => steps.length;
}