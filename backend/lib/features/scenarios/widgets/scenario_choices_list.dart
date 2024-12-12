import 'package:flutter/material.dart';
import 'package:backend/theme/app_theme.dart';
import '../../scenarios/models/scenario_choice.dart';

class ScenarioChoicesList extends StatelessWidget {
  final List<ScenarioChoice> choices;
  final int currentScenarioIndex;
  final bool flowersPurchased;
  final bool chocolatesPurchased;
  final List<Color> optionColors;
  final Function(ScenarioChoice) onChoiceSelected;
  final Function(String) onLockedChoice;

  const ScenarioChoicesList({
    Key? key,
    required this.choices,
    required this.currentScenarioIndex,
    required this.flowersPurchased,
    required this.chocolatesPurchased,
    required this.optionColors,
    required this.onChoiceSelected,
    required this.onLockedChoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left:16.0, right:16.0, top:16.0, bottom:28.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: choices.asMap().entries.map((entry) {
          final index = entry.key;
          final choice = entry.value;

          bool locked = false;

          if (choice.text.contains("flowers") && !flowersPurchased) {
            locked = true;
          } else if (choice.text.contains("chocolates") && !chocolatesPurchased) {
            locked = true;
          }


          Color bgColor = locked ? Colors.white : optionColors[index % optionColors.length];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 12),
            width: maxWidth - 48,
            child: InkWell(
              onTap: locked
                  ? () {
                      onLockedChoice("Please purchase the required item first from the shop.");
                    }
                  : () => onChoiceSelected(choice),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: locked ? AppTheme.klooigeldBlauw : Colors.transparent,
                    width: locked ? 2 : 0,
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  choice.text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontWeight: FontWeight.w600,
                    fontSize:14,
                    color: locked ? AppTheme.klooigeldBlauw : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
