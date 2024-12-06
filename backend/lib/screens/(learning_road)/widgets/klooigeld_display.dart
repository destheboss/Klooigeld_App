import 'package:flutter/material.dart';

class KlooigeldDisplay extends StatelessWidget {
  final double balance;

  const KlooigeldDisplay({Key? key, required this.balance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$balance",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black, 
          ),
        ),
        SizedBox(width: 4),
        Image.asset(
          'assets/symbols/klooigeld_symbol.png',
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
