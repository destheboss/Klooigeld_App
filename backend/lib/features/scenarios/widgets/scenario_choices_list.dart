// lib/features/scenarios/widgets/scenario_choices_list.dart
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
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: choices.asMap().entries.map((entry) {
          final index = entry.key;
          final choice = entry.value;

          bool locked = false;
          String displayText = choice.text;

          // If the user references “flowers” or “chocolates” but doesn’t have them purchased, show locked
          if (choice.text.contains("flowers")) {
            if (!flowersPurchased) {
              locked = true;
            } else {
              displayText = "Give the flowers";
            }
          } else if (choice.text.contains("chocolates")) {
            if (!chocolatesPurchased) {
              locked = true;
            } else {
              displayText = "Give the chocolates";
            }
          }

          Color bgColor = locked ? Colors.white : optionColors[index % optionColors.length];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 12),
            width: maxWidth - 48,
            child: InkWell(
              onTap: locked
                  ? () => onLockedChoice("Please purchase the required item first from the shop.")
                  : () => onChoiceSelected(choice),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: locked
                      ? Border.all(color: AppTheme.klooigeldBlauw, width: 2)
                      : null,
                ),
                alignment: Alignment.centerLeft,
                child: _formatChoiceText(displayText, locked),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _formatChoiceText(String text, bool locked) {
    final regex = RegExp(r'(\d+)K');
    final matches = regex.allMatches(text);

    List<InlineSpan> children = [];
    int lastMatchEnd = 0;
    TextStyle textStyle = TextStyle(
      fontFamily: AppTheme.neighbor,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: locked ? AppTheme.klooigeldBlauw : Colors.white,
      height: 1.4,
    );

    for (var match in matches) {
      if (match.start > lastMatchEnd) {
        children.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: textStyle,
        ));
      }
      children.add(TextSpan(text: match.group(1), style: textStyle));
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Image.asset(
            locked ? 'assets/images/currency_blaw.png' : 'assets/images/currency_white.png',
            width: 10,
            height: 10,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      children.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: textStyle,
      ));
    }

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(children: children),
    );
  }
}
