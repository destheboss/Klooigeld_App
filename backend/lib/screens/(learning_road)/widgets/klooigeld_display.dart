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
          ),
        ),
        SizedBox(width: 4),
        Icon(
          Icons.attach_money,
          color: Colors.green,
          size: 20,
        ),
      ],
    );
  }
}
