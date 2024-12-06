import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final String description;
  final String date;
  final String amount;

  const TransactionTile({
    Key? key,
    required this.description,
    required this.date,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the numerical part of the amount
    String amountValue = amount.replaceAll(' K', ''); // Removes ' K'

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Transaction details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                description,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: AppTheme.neighbor,
                      color: Colors.black,
                      fontSize: 16,
                    ),
              ),
              Row(
                children: [
                  Text(
                    amountValue,
                    style: TextStyle(
                      fontFamily: AppTheme.neighbor,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Transform.translate(
                    offset: const Offset(0, 0.3),
                    child: Image.asset(
                      'assets/images/currency.png',
                      width: 13,
                      height: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: AppTheme.neighbor,
                    color: Colors.black54,
                    fontSize: 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
