// widgets/inverted_trapezoid_shadow.dart

import 'package:flutter/material.dart';

class InvertedTrapezoidShadowPainter extends CustomPainter {
  final double radius;
  final Color shadowColor;
  final double elevation;

  InvertedTrapezoidShadowPainter({
    required this.radius,
    required this.shadowColor,
    required this.elevation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final double inset = size.width * 0.05;
    final double r = radius.clamp(0.0, inset);

    final Path shadowPath = Path()
      ..moveTo(rect.left + r, rect.top + elevation)
      ..lineTo(rect.right - r, rect.top + elevation)
      ..arcToPoint(
        Offset(rect.right, rect.top + r + elevation),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(rect.right - inset, rect.bottom - r + elevation)
      ..arcToPoint(
        Offset(rect.right - inset - r, rect.bottom + elevation),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(rect.left + inset + r, rect.bottom + elevation)
      ..arcToPoint(
        Offset(rect.left + inset, rect.bottom - r + elevation),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(rect.left, rect.top + r + elevation)
      ..arcToPoint(
        Offset(rect.left + r, rect.top + elevation),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..close();

    final Paint paint = Paint()
      ..color = shadowColor.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, elevation);

    canvas.drawPath(shadowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
