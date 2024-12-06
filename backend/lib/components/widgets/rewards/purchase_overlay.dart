import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PurchaseOverlay extends StatefulWidget {
  final String itemName;
  final String imagePath;
  final int itemPrice;
  final List<Color> colors;
  final VoidCallback onBuy;
  final VoidCallback onCancel;

  const PurchaseOverlay({
    super.key,
    required this.itemName,
    required this.imagePath,
    required this.itemPrice,
    required this.colors,
    required this.onBuy,
    required this.onCancel,
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
    return WillPopScope(
      onWillPop: () async {
        widget.onCancel();
        return false; // Prevent navigating back to the previous screen
      },
      child: Stack(
        children: [
          // Background that closes on tap
          GestureDetector(
            onTap: widget.onCancel,
            child: Container(
              color: Colors.black54,
            ),
          ),
          // Foreground card
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
                    // Image with paars background
                    Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        color: AppTheme.klooigeldPaars,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.itemName,
                      style: TextStyle(
                        fontFamily: AppTheme.titleFont, // Title font for item name
                        fontSize: 24,
                        color: AppTheme.nearlyBlack2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Colors row with selectable colors
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.colors.length, (i) {
                        final isSelected = i == selectedColorIndex;
                        final color = widget.colors[i];
                        // Determine border based on color and selection
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

                    // Price with image for currency
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
                            width: 14, // Adjust size as needed
                            height: 14, // Adjust size as needed
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Buttons row with equal width
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onBuy,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.klooigeldGroen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.klooigeldRoze,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
