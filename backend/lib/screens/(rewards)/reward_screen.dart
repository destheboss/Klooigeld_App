import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend/screens/(rewards)/models/reward_item.dart';
import 'package:backend/screens/(rewards)/data/rewards_data.dart';
import 'package:backend/screens/(rewards)/widgets/reward_item_widget.dart';

class RewardsShopScreen extends StatefulWidget {
  const RewardsShopScreen({super.key});

  @override
  RewardsShopScreenState createState() => RewardsShopScreenState();
}

class RewardsShopScreenState extends State<RewardsShopScreen> {
  int balance = 0;
  List<String> purchasedRewards = [];

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _loadPurchasedRewards();
  }

  Future<void> _loadBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // Added mounted check
    setState(() {
      balance = prefs.getInt('balance') ?? 0;
    });
  }

  Future<void> _loadPurchasedRewards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // Added mounted check
    setState(() {
      purchasedRewards = prefs.getStringList('purchased_rewards') ?? [];
    });
  }

  void _purchaseReward(RewardItem reward) async {
    if (balance >= reward.cost) {
      setState(() {
        balance -= reward.cost;
        purchasedRewards.add(reward.id.toString());
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('balance', balance);
      await prefs.setStringList('purchased_rewards', purchasedRewards);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You purchased ${reward.name}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient funds')),
      );
    }
  }

  void _addCurrency(int amount) async {
    setState(() {
      balance += amount;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('balance', balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clooi Shop'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // TODO: Replace with navigation to the Home Screen when implemented
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance display with border and background color
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(8.0), // Padding inside the container
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(200,187,243,0.7), // Set background color to lime green
                  border: Border.all(color: Colors.grey), // Add border
                  borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
                ),
                child: Text(
                  'Balance: \$${balance.toString()}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Add currency button (for testing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _addCurrency(500);
                },
                child: Text('Add \$500'),
              ),
            ),
            // Badges section
            _buildSection('Badges', RewardCategory.badge),
            // Upgrades section
            _buildSection('Upgrades', RewardCategory.upgrade),
            // Limited Edition Rewards section
            _buildSection('Limited Edition Rewards', RewardCategory.limitedEdition),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, RewardCategory category) {
    // Filter rewards based on category
    final items = rewardsList.where((item) => item.category == category).toList();

    if (items.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Horizontal list of rewards with border
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.lime,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SizedBox(
              height: 220, // Adjust as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final reward = items[index];
                  bool isOwned = purchasedRewards.contains(reward.id.toString());
                  bool isAffordable = balance >= reward.cost;

                  return RewardItemWidget(
                    reward: reward,
                    isOwned: isOwned,
                    isAffordable: isAffordable,
                    onPurchase: () {
                      _purchaseReward(reward);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
