import 'package:backend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class Textbox {

final int id;
final String text;
final String type;
final double? cost;
final IconData? icon;


Textbox( 
  this.cost, 
  this.icon, {
  required this.id,
  required this.text,
  required this.type,
});
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isFromLeft;
  final IconData icon;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isFromLeft,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: isFromLeft
          ? [
              Icon(icon, color: AppTheme.klooigeldBlauw, size: 24),
              SizedBox(width: 8),
              Bubble(text: text, isFromLeft: isFromLeft),
            ]
          : [
              Bubble(text: text, isFromLeft: isFromLeft),
              SizedBox(width: 8),
              Icon(icon, color: AppTheme.klooigeldRoze, size: 24),
            ],
    );
  }
}

class Bubble extends StatelessWidget {
  final String text;
  final bool isFromLeft;

  const Bubble({
    Key? key,
    required this.text,
    required this.isFromLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: isFromLeft ? AppTheme.klooigeldPaars : AppTheme.klooigeldRozeAlt,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFromLeft ? 0 : 15),
          topRight: Radius.circular(isFromLeft ? 15 : 0),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}

class AnswersBox extends StatelessWidget {
  final String answer;
  final double cost;
  final VoidCallback onTap;

  const AnswersBox({
    Key? key,
    required this.answer,
    required this.cost,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              answer,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "\$${cost.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 16, color: AppTheme.klooigeldGroen),
            ),
          ],
        ),
      ),
    );
  }
}