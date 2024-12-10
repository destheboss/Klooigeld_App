import 'package:flutter/material.dart';

class ProgressLinePainter extends CustomPainter {
  final double progress;
    static const Color klooigeldBlauw = Color(0xFF1D1999); // New: Button & pop-up background / Button text


  ProgressLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

<<<<<<< Updated upstream
    Paint progressPaint = Paint()
=======
    final barRect = Rect.fromLTWH(
      0,
      (size.height - barHeight) / 2,
      size.width,
      barHeight,
    );
    final barRRect = RRect.fromRectAndRadius(barRect, Radius.circular(barRadius));

    Paint borderPaint = Paint()
>>>>>>> Stashed changes
      ..color = klooigeldBlauw
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

<<<<<<< Updated upstream
    double startX = 16.0;
    double endX = size.width - 16.0;
    double progressX = startX + (endX - startX) * progress;

    // Draw the full line
    canvas.drawLine(Offset(startX, size.height / 2),
        Offset(endX, size.height / 2), linePaint);

    // Draw the progress line
    canvas.drawLine(Offset(startX, size.height / 2),
        Offset(progressX, size.height / 2), progressPaint);
=======
    Paint fillPaint = Paint()
      ..color = klooigeldBlauw
      ..style = PaintingStyle.fill;

    canvas.drawRRect(barRRect, borderPaint);

    final fillWidth = size.width * progress;
    if (fillWidth > 0) {
      final fillRect = Rect.fromLTWH(
        0,
        (size.height - barHeight) / 2,
        fillWidth,
        barHeight,
      );
      final fillRRect = RRect.fromRectAndRadius(fillRect, Radius.circular(barRadius));
      canvas.drawRRect(fillRRect, fillPaint);
    }
>>>>>>> Stashed changes
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}