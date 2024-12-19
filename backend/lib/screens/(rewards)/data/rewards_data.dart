import 'package:backend/screens/(rewards)/models/reward_item.dart';

const List<RewardItem> rewardsList = [
  RewardItem(
    id: 1,
    name: 'Gold Badge',
    description: 'Awarded for excellence',
    cost: 100,
    imagePath: 'assets/images/rewards/gold_badge.png',
    category: RewardCategory.badge,
  ),
  RewardItem(
    id: 2,
    name: 'Silver Badge',
    description: 'A symbol of achievement',
    cost: 75,
    imagePath: 'assets/images/rewards/silver_badge.png',
    category: RewardCategory.badge,
  ),
  RewardItem(
    id: 3,
    name: 'Bronze Badge',
    description: 'For effort',
    cost: 3050,
    imagePath: 'assets/images/rewards/bronze_badge.png',
    category: RewardCategory.badge,
  ),
  RewardItem(
    id: 4,
    name: 'Shield Badge',
    description: 'Special item',
    cost: 150,
    imagePath: 'assets/images/rewards/shield_badge.png',
    category: RewardCategory.limitedEdition,
  ),
  RewardItem(
    id: 5,
    name: 'Speed Boost',
    description: 'Increases speed',
    cost: 120,
    imagePath: 'assets/images/rewards/speed_boost.png',
    category: RewardCategory.upgrade,
  ),
];
