import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ShopItemCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final int price;
  final List<Color> colors;
  final VoidCallback onTap;

  /// If true, visually indicate that the item has already been purchased
  final bool isPurchased;

  const ShopItemCard({
    super.key,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.colors,
    required this.onTap,
    this.isPurchased = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppTheme.klooigeldPaars.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.klooigeldPaars,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: AppTheme.neighbor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: colors
                            .map((c) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: c == Colors.white
                                        ? Border.all(color: Colors.black, width: 1)
                                        : null,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '$price',
                            style: TextStyle(
                              fontFamily: AppTheme.neighbor,
                              fontSize: 14,
                              color: AppTheme.black,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Transform.translate(
                            offset: const Offset(0, 0.2),
                            child: Image.asset(
                              'assets/images/currency.png',
                              width: 10,
                              height: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // "PURCHASED" overlay if the item is already purchased
          if (isPurchased)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "PURCHASED",
                    style: TextStyle(
                      fontFamily: AppTheme.neighbor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
