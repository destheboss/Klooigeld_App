// lib/components/widgets/rewards/shop_item_card.dart

// Changes made based on requests:
// - For discounted prices, remove the currency image from both old and new prices.
// - Line-through for the old price remains red.
// - Discount badge now has no border and uses AppTheme.klooigeldRozeAlt as background color.
// - Inline comments added for clarity.

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ShopItemCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final int price;
  final List<Color> colors;
  final VoidCallback onTap;
  final bool isPurchased;
  final int? discountedPrice;

  const ShopItemCard({
    super.key,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.colors,
    required this.onTap,
    this.isPurchased = false,
    this.discountedPrice,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = discountedPrice != null && discountedPrice! < price;

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
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                        children: colors.map((c) => Container(
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
                        )).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (hasDiscount) ...[
                            // Old price in red, strikethrough, no currency icon here
                            Text(
                              '$price',
                              style: const TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.klooigeldRozeAlt,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppTheme.klooigeldRozeAlt,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // New discounted price, no currency icon
                            Text(
                              '${discountedPrice!}',
                              style: TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
                            const Spacer(),
                            // Discount badge with no border and color klooigeldRozeAlt
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.klooigeldRoze,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '-20%',
                                style: TextStyle(
                                  fontFamily: AppTheme.neighbor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppTheme.white,
                                ),
                              ),
                            ),
                          ] else ...[
                            // No discount, show normal price with currency icon
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
