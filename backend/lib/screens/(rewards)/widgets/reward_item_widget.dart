import 'package:flutter/material.dart';
import 'package:backend/screens/(rewards)/models/reward_item.dart';

class RewardItemWidget extends StatelessWidget {
  final RewardItem reward;
  final VoidCallback onPurchase;
  final bool isOwned;
  final bool isAffordable;

  const RewardItemWidget({
    super.key,
    required this.reward,
    required this.onPurchase,
    required this.isOwned,
    required this.isAffordable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            // Reward image
            Expanded(
              child: Image.asset(
                reward.imagePath,
                fit: BoxFit.cover,
              ),
            ),
            // Reward name
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                reward.name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            // Reward cost
            Text(
              '\$${reward.cost}',
              style: TextStyle(
                color: isAffordable ? Colors.grey : Colors.red, // Change color based on affordability
              ),
            ),
            // Purchase button or owned icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: isOwned
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                      onPressed: isAffordable ? onPurchase : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAffordable ? null : Colors.grey,
                      ),
                      child: Text('Buy'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
