import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    // Split the amount to separate the 'K' from the numbers
    String amountValue = amount.replaceAll(' K', '');
    String currencySymbol = 'K';

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
                        offset: Offset(0, 2),
                        child: Text(
                          currencySymbol,
                          style: TextStyle(
                            fontFamily: AppTheme.logoFont1,
                            fontSize: 18,
                            color: Colors.black,
                          ),
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
