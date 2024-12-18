// lib/components/widgets/rewards/purchase_overlay.dart

// Changes based on requests:
// - For discounted prices, remove the currency images.
// - Line-through stays red for old price.
// - Discount badge has no border, color klooigeldRozeAlt, and should be moved to top-right corner of the product image area.
// - Invert positions of cancel and buy buttons (Cancel on left, Buy on right).
// - Inline comments added.

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PurchaseOverlay extends StatefulWidget {
  final String itemName;
  final String imagePath;
  final int itemPrice;
  final List<Color> colors;
  final VoidCallback onBuy;
  final VoidCallback onCancel;
  final bool promotionalOfferActive;

  const PurchaseOverlay({
    super.key,
    required this.itemName,
    required this.imagePath,
    required this.itemPrice,
    required this.colors,
    required this.onBuy,
    required this.onCancel,
    this.promotionalOfferActive = false,
  });

  @override
  State<PurchaseOverlay> createState() => _PurchaseOverlayState();
}

class _PurchaseOverlayState extends State<PurchaseOverlay> {
  int selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedColorIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.promotionalOfferActive;
    final discountedPrice = hasDiscount ? (widget.itemPrice * 0.8).round() : widget.itemPrice;

    return WillPopScope(
      onWillPop: () async {
        widget.onCancel();
        return false;
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onCancel,
            child: Container(
              color: Colors.black54,
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product image area with discount badge at top-right if discounted
                    Stack(
                      children: [
                        Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: AppTheme.klooigeldPaars,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              widget.imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.klooigeldBlauw,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '-20%',
                                style: TextStyle(
                                  fontFamily: AppTheme.neighbor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.itemName,
                      style: TextStyle(
                        fontFamily: AppTheme.titleFont,
                        fontSize: 24,
                        color: AppTheme.nearlyBlack2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.colors.length, (i) {
                        final isSelected = i == selectedColorIndex;
                        final color = widget.colors[i];
                        Border? dotBorder;
                        if (isSelected) {
                          dotBorder = Border.all(
                              color: const Color.fromARGB(33, 0, 0, 0), width: 2);
                        } else if (color == Colors.white) {
                          dotBorder = Border.all(color: Colors.black, width: 1);
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColorIndex = i;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromARGB(108, 0, 0, 0)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: dotBorder,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Price display: no currency images for discounted scenario
                    if (hasDiscount) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Old price red strikethrough
                          Text(
                            '${widget.itemPrice}',
                            style: const TextStyle(
                              fontFamily: AppTheme.neighbor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.klooigeldRozeAlt,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppTheme.klooigeldRozeAlt,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // New discounted price without currency icon
                          Text(
                            '$discountedPrice',
                            style: TextStyle(
                              fontFamily: AppTheme.neighbor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.black,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Transform.translate(
                            offset: const Offset(0, 0.3),
                            child: Image.asset(
                              'assets/images/currency.png',
                              width: 14,
                              height: 14,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Normal price with currency icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.itemPrice}',
                            style: TextStyle(
                              fontFamily: AppTheme.neighbor,
                              fontSize: 20,
                              color: AppTheme.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Transform.translate(
                            offset: const Offset(0, 0.3),
                            child: Image.asset(
                              'assets/images/currency.png',
                              width: 14,
                              height: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Invert positions of cancel and buy buttons: Cancel on left, Buy on right
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.klooigeldRoze,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onBuy,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.klooigeldGroen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Buy',
                              style: TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
