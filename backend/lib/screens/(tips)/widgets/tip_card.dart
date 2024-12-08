// tip_card.dart

import 'package:flutter/material.dart';
import '../models/tip_category.dart';
import '/theme/app_theme.dart';
import 'inverted_trapezoid_border.dart';
import 'inverted_trapezoid_shadow.dart';

class TipCard extends StatelessWidget {
  final TipCategory category;
  final VoidCallback onTap;

  final Color? cardColor;
  final IconData? icon;
  final String? title;
  final double? progress;
  final double radius;
  final double elevation;
  final Color shadowColor;

  const TipCard({
    super.key,
    required this.category,
    required this.onTap,
    this.cardColor,
    this.icon,
    this.title,
    this.progress,
    this.radius = 16,
    this.elevation = 10,
    this.shadowColor = const Color.fromARGB(34, 58, 58, 58),
  });

  @override
  Widget build(BuildContext context) {
    final double actualProgress = progress ?? category.progress;
    final int percentage = (actualProgress * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shadow layer
          Positioned(
            top: -8,
            left: -2,
            right: -2,
            bottom: 5,
            child: CustomPaint(
              painter: InvertedTrapezoidShadowPainter(
                radius: radius,
                shadowColor: shadowColor,
                elevation: 7,
              ),
            ),
          ),

          // The card itself
          Material(
            shape: InvertedTrapezoidBorder(radius: radius),
            elevation: 0,
            shadowColor: Colors.transparent,
            color: cardColor ?? category.backgroundColor,
            clipBehavior: Clip.none,
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(18),
              alignment: Alignment.topLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon ?? category.icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title ?? category.title,
                      style: TextStyle(
                        fontFamily: AppTheme.titleFont,
                        fontSize: 20,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ProgressBarWithPercentage(
                    progress: actualProgress,
                    percentage: percentage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBarWithPercentage extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int percentage;

  const _ProgressBarWithPercentage({
    required this.progress,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final barWidth = 60.0;
    final barHeight = 8.0;
    final fillWidth = barWidth * progress;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(4),
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              Container(
                width: fillWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontFamily: AppTheme.neighbor,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
