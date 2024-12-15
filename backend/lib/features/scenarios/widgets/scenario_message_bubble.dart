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
    // Convert 'K' to a currency icon, etc.
    final regex = RegExp(r'(\d+)K');
    final matches = regex.allMatches(message);

    List<InlineSpan> children = [];
    int lastMatchEnd = 0;
    TextStyle baseTextStyle = TextStyle(
      fontFamily: AppTheme.neighbor,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      color: Colors.black,
      height: 1.4,
    );

    for (var match in matches) {
      if (match.start > lastMatchEnd) {
        children.add(TextSpan(
          text: message.substring(lastMatchEnd, match.start),
          style: baseTextStyle,
        ));
      }
      // number
      children.add(TextSpan(
        text: '${match.group(1)}\u{200B}', // zero-width space
        style: baseTextStyle,
      ));
      // icon
      children.add(
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
    if (lastMatchEnd < message.length) {
      children.add(TextSpan(
        text: message.substring(lastMatchEnd),
        style: baseTextStyle,
      ));
    }

    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(children: children),
    );
  }
}
