// lib/features/scenarios/widgets/scenario_header.dart
import 'package:flutter/material.dart';
import 'package:backend/theme/app_theme.dart';

class ScenarioHeader extends StatelessWidget {
  final VoidCallback onBack;
  final int klooicash;
  final double progress;

  const ScenarioHeader({
    Key? key,
    required this.onBack,
    required this.klooicash,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.klooigeldBlauw, width: 2),
                      ),
                      child: const Icon(Icons.chevron_left_rounded, size: 30, color: AppTheme.klooigeldBlauw),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('BUY NOW,',
                      style: TextStyle(
                        fontFamily: AppTheme.titleFont,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.klooigeldRozeAlt,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text('PAY LATER',
                      style: TextStyle(
                        fontFamily: AppTheme.titleFont,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.klooigeldBlauw,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        klooicash.toString(),
                        style: TextStyle(
                          fontFamily: AppTheme.neighbor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppTheme.klooigeldBlauw,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/currency_blaw.png',
                        width: 16,
                        height: 13,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: CustomPaint(
              painter: _ProgressLinePainter(progress: progress),
              child: Container(height: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLinePainter extends CustomPainter {
  final double progress;
  static const Color klooigeldBlauw = Color(0xFF1D1999);

  _ProgressLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double barHeight = 30.0;
    final double barRadius = barHeight / 2.0;

    final barRect = Rect.fromLTWH(0, (size.height - barHeight) / 2, size.width, barHeight);
    final barRRect = RRect.fromRectAndRadius(barRect, Radius.circular(barRadius));

    Paint borderPaint = Paint()
      ..color = klooigeldBlauw
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Paint fillPaint = Paint()
      ..color = klooigeldBlauw
      ..style = PaintingStyle.fill;

    // Draw border
    canvas.drawRRect(barRRect, borderPaint);

    // Fill portion
    final fillWidth = size.width * progress;
    if (fillWidth > 0) {
      final fillRect = Rect.fromLTWH(0, (size.height - barHeight) / 2, fillWidth, barHeight);
      final fillRRect = RRect.fromRectAndRadius(fillRect, Radius.circular(barRadius));
      canvas.drawRRect(fillRRect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
