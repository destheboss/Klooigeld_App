// widgets/tip_overlay.dart

import 'package:flutter/material.dart';
import '/theme/app_theme.dart';
import '../models/tip_category.dart';
import '../services/tip_service.dart';

class TipOverlay extends StatelessWidget {
  final TipCategory category;
  final VoidCallback onClose;

  const TipOverlay({super.key, required this.category, required this.onClose});

  Future<void> _markAsRead() async {
    await TipService.markCategoryRead(category);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: WillPopScope(
        onWillPop: () async {
          await _markAsRead();
          onClose();
          return false;
        },
        child: GestureDetector(
          onTap: () async {
            await _markAsRead();
            onClose();
          },
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                color: AppTheme.white,
                elevation: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon and title
                            Row(
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.backgroundColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  category.title,
                                  style: TextStyle(
                                    fontFamily: AppTheme.titleFont,
                                    fontSize: 28,
                                    color: AppTheme.nearlyBlack2,
                                  ),
                                ),
                              ],
                            ),

                            // Close button with color matching the card
                            InkWell(
                              onTap: () async {
                                await _markAsRead();
                                onClose();
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: category.backgroundColor, width: 1.8),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 19,
                                  color: category.backgroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tips
                        ...category.tips.map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip.title,
                                    style: TextStyle(
                                      fontFamily: AppTheme.neighbor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: AppTheme.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tip.description,
                                    style: TextStyle(
                                      fontFamily: AppTheme.neighbor,
                                      fontSize: 14,
                                      color: AppTheme.black,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
