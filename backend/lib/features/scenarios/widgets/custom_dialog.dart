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

  /// Helper function to parse content with **bold** syntax and replace 'K' with an image
  List<InlineSpan> parseContent(String content, TextStyle normalStyle, TextStyle boldStyle) {
    final RegExp boldRegExp = RegExp(r'\*\*(.*?)\*\*');
    final List<InlineSpan> spans = [];
    int currentIndex = 0;

    // Find all bold matches
    for (final Match match in boldRegExp.allMatches(content)) {
      // Text before the bold text
      if (match.start > currentIndex) {
        String normalText = content.substring(currentIndex, match.start);
        spans.addAll(_processCurrency(normalText, normalStyle));
      }

      // Bold text without the ** markers
      String boldText = match.group(1)!;
      spans.addAll(_processCurrency(boldText, boldStyle, isBold: true));

      currentIndex = match.end;
    }

    // Remaining text after the last bold text
    if (currentIndex < content.length) {
      String remainingText = content.substring(currentIndex);
      spans.addAll(_processCurrency(remainingText, normalStyle));
    }

    return spans;
  }

  /// Processes text to replace 'K' with currency image
  List<InlineSpan> _processCurrency(String text, TextStyle style, {bool isBold = false}) {
    final RegExp currencyRegex = RegExp(r'(\d+)K');
    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final Match match in currencyRegex.allMatches(text)) {
      // Text before the currency match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }

      // Number before 'K'
      String number = match.group(1)!;
      spans.add(TextSpan(
        text: '$number\u{200B}', // Zero-width space to prevent merging with the image
        style: style,
      ));

      // Currency icon with Transform.translate for alignment
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform.translate(
            offset: const Offset(0, -0.9), // Adjust the vertical offset as needed
            child: Image.asset(
              'assets/images/currency.png',
              width: 11,
              height: 11.5,
            ),
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Text after the last currency match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    // Define the text styles
    final TextStyle normalStyle = TextStyle(
      fontFamily: AppTheme.neighbor,
      fontSize: 16,
      color: AppTheme.black,
    );

    final TextStyle boldStyle = TextStyle(
      fontFamily: AppTheme.neighbor,
      fontSize: 16,
      color: AppTheme.black,
      fontWeight: FontWeight.bold,
    );

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
              // Content with RichText
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: parseContent(content, normalStyle, boldStyle),
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.max,
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
