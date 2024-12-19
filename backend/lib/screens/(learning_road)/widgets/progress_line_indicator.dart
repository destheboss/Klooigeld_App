import 'package:flutter/material.dart';

class ProgressLinePainter extends CustomPainter {
  final double progress;
  static const Color klooigeldBlauw = Color(0xFF1D1999);

  ProgressLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double barHeight = 20.0;
    final double barRadius = barHeight / 2.0;

    // Define the overall progress bar rect
    final barRect = Rect.fromLTWH(
      0,
      (size.height - barHeight) / 2,
      size.width,
      barHeight,
    );
    final barRRect = RRect.fromRectAndRadius(barRect, Radius.circular(barRadius));

    // Border paint
    Paint borderPaint = Paint()
      ..color = klooigeldBlauw
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Fill paint
    Paint fillPaint = Paint()
      ..color = klooigeldBlauw
      ..style = PaintingStyle.fill;

    // Draw the bordered, rounded progress track
    canvas.drawRRect(barRRect, borderPaint);

    // Calculate fill width based on progress
    final fillWidth = size.width * progress;
    if (fillWidth > 0) {
      final fillRect = Rect.fromLTWH(
        0,
        (size.height - barHeight) / 2,
        fillWidth,
        barHeight,
      );
      final fillRRect = RRect.fromRectAndRadius(fillRect, Radius.circular(barRadius));

      // Draw the filled portion
      canvas.drawRRect(fillRRect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
