// widgets/inverted_trapezoid_border.dart

import 'package:flutter/material.dart';

class InvertedTrapezoidBorder extends ShapeBorder {
  final double radius;
  const InvertedTrapezoidBorder({this.radius = 16});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => InvertedTrapezoidBorder(radius: radius * t);

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) => t < 0.5 ? a : this;

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) => t > 0.5 ? b : this;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double inset = rect.width * 0.05;
    final double r = radius.clamp(0.0, inset);

    Path path = Path();

    // Start at top-left corner arc
    path.moveTo(rect.left + r, rect.top);

    // Top edge
    path.lineTo(rect.right - r, rect.top);

    // Top-right concave corner arc
    path.arcToPoint(
      Offset(rect.right, rect.top + r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Right edge
    path.lineTo(rect.right - inset, rect.bottom - r);

    // Bottom-right concave corner arc
    path.arcToPoint(
      Offset(rect.right - inset - r, rect.bottom),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Bottom edge
    path.lineTo(rect.left + inset + r, rect.bottom);

    // Bottom-left concave corner arc
    path.arcToPoint(
      Offset(rect.left + inset, rect.bottom - r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // Left edge
    path.lineTo(rect.left, rect.top + r);

    // Top-left concave corner arc
    path.arcToPoint(
      Offset(rect.left + r, rect.top),
      radius: Radius.circular(r),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // No custom painting needed
  }
}
