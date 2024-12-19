enum RewardCategory {
  badge,
  upgrade,
  limitedEdition,
}

class RewardItem {
  final int id;
  final String name;
  final String description;
  final int cost;
  final String imagePath;
  final RewardCategory category;

  const RewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.imagePath,
    required this.category,
  });
}
