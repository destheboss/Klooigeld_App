import 'dart:ui';
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

    Paint progressPaint = Paint()
      ..color = klooigeldBlauw
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    double startX = 16.0;
    double endX = size.width - 16.0;
    double progressX = startX + (endX - startX) * progress;

    // Draw the full line
    canvas.drawLine(Offset(startX, size.height / 2),
        Offset(endX, size.height / 2), linePaint);

    // Draw the progress line
    canvas.drawLine(Offset(startX, size.height / 2),
        Offset(progressX, size.height / 2), progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}