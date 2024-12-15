// lib/features/scenarios/widgets/scenario_message_bubble.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:backend/theme/app_theme.dart';

class ScenarioMessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final String? avatarImagePath;

  const ScenarioMessageBubble({
    Key? key,
    required this.msg,
    this.avatarImagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final type = msg["type"];
    final ImageProvider<Object> userAvatar =
        (avatarImagePath != null && File(avatarImagePath!).existsSync())
            ? FileImage(File(avatarImagePath!)) as ImageProvider<Object>
            : const AssetImage('assets/images/default_user.png') as ImageProvider<Object>;

    if (type == "npc") {
      return _buildNPCMessage(msg);
    } else if (type == "user") {
      return _buildUserMessage(msg, userAvatar);
    } else if (type == "outcome") {
      return _buildOutcomeMessage(msg);
    }
    return const SizedBox.shrink();
  }

  Widget _buildNPCMessage(Map<String, dynamic> msg) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.klooigeldPaars,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                msg["speaker"],
                style: TextStyle(
                  fontFamily: AppTheme.neighbor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.klooigeldBlauw,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.klooigeldPaars,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: _formatMessageText(msg["message"]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(Map<String, dynamic> msg, ImageProvider<Object> userAvatar) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                msg["speaker"],
                style: TextStyle(
                  fontFamily: AppTheme.neighbor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.klooigeldBlauw,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.klooigeldBlauw,
                backgroundImage: userAvatar,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.klooigeldRozeAlt,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: _formatMessageText(msg["message"]),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Center(child: _formatMessageText(msg["message"])),
      ),
    );
  }

  Widget _formatMessageText(String message) {
    // Regular expressions to identify bold text and currency patterns
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final currencyRegex = RegExp(r'(\d+)K');

    List<InlineSpan> children = [];
    int currentIndex = 0;

    // Find all bold matches
    Iterable<RegExpMatch> boldMatches = boldRegex.allMatches(message);

    for (final match in boldMatches) {
      // Text before the bold text
      if (match.start > currentIndex) {
        String normalText = message.substring(currentIndex, match.start);
        children.addAll(_processCurrency(normalText, currencyRegex));
      }

      // Bold text without the ** markers
      String boldText = match.group(1)!;
      children.addAll(_processBoldAndCurrency(boldText, currencyRegex));

      currentIndex = match.end;
    }

    // Remaining text after the last bold text
    if (currentIndex < message.length) {
      String remainingText = message.substring(currentIndex);
      children.addAll(_processCurrency(remainingText, currencyRegex));
    }

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(children: children),
    );
  }

  List<InlineSpan> _processCurrency(String text, RegExp currencyRegex) {
    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in currencyRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontFamily: AppTheme.neighbor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
            height: 1.4,
          ),
        ));
      }

      // Number before 'K'
      String number = match.group(1)!;
      spans.add(TextSpan(
        text: '$number\u{200B}',
        style: TextStyle(
          fontFamily: AppTheme.neighbor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black,
          height: 1.4,
        ),
      ));

      // Currency icon
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform.translate(
            offset: const Offset(0, -0.3),
            child: Image.asset('assets/images/currency.png', width: 10, height: 10),
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Text after the last currency match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          fontFamily: AppTheme.neighbor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black,
          height: 1.4,
        ),
      ));
    }

    return spans;
  }

  List<InlineSpan> _processBoldAndCurrency(String text, RegExp currencyRegex) {
    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    Iterable<RegExpMatch> currencyMatches = currencyRegex.allMatches(text);

    for (final match in currencyMatches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontFamily: AppTheme.neighbor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
            height: 1.4,
          ),
        ));
      }

      // Number before 'K'
      String number = match.group(1)!;
      spans.add(TextSpan(
        text: '$number\u{200B}',
        style: TextStyle(
          fontFamily: AppTheme.neighbor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
          height: 1.4,
        ),
      ));

      // Currency icon
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform.translate(
            offset: const Offset(0, -0.3),
            child: Image.asset('assets/images/currency.png', width: 10, height: 10),
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Text after the last currency match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          fontFamily: AppTheme.neighbor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
          height: 1.4,
        ),
      ));
    }

    return spans;
  }
}
