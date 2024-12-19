// NEW FILE: lib/components/widgets/account/rounded_dropdown.dart
// A reusable dropdown widget styled similarly to the text field, 
// ensuring DRY and a consistent look.

import 'package:flutter/material.dart';

class RoundedDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final Color textColor;

  const RoundedDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: textColor.withOpacity(0.9),
      iconEnabledColor: textColor,
      style: TextStyle(color: textColor, fontSize: 14),
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
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: TextStyle(color: textColor)),
        );
      }).toList(),
    );
  }
}
