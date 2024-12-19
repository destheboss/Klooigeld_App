// NEW FILE: lib/components/widgets/account/rounded_text_field.dart
// A reusable text field widget with custom styling for white text on colored backgrounds.

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color textColor;
  final TextInputType keyboardType;

  const RoundedTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.textColor,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 14),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textColor.withOpacity(0.7)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: textColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: textColor, width: 2),
        ),
      ),
    );
  }
}
