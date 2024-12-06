// import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class RoadmapPainter extends CustomPainter {
  static const Color klooigeldDarkGroen = Color(0xFFB2DF1F);
  static const Color white = Colors.white;

  final int numberOfStops;
  final double progress; // Progress of the green road (0.0 to 1.0)
  final List<Offset> stopPositions = [];

  RoadmapPainter(this.numberOfStops, this.progress);

  void calculateStopPositions(Size size) {
    stopPositions.clear();

    double lineLength = size.width * 0.4;
    double circleRadius = size.width * 0.20;
    double startX = circleRadius + (size.width - lineLength - circleRadius * 2) / 2;
    double verticalMargin = size.height * 0.05;
    double startY = verticalMargin;

    bool goingRight = true;

    for (int i = 0; i < numberOfStops; i++) {
      stopPositions.add(Offset(startX, startY));

      if (goingRight) {
        startX += lineLength;
      } else {
        startX -= lineLength;
      }

      startY += 2 * circleRadius;
      goingRight = !goingRight;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    calculateStopPositions(size);

    Paint whitePaint = Paint()
      ..color = white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    Paint greenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 21;

    Path path = Path();

    double lineLength = size.width * 0.4;
    double circleRadius = size.width * 0.20;
    double startX = circleRadius + (size.width - lineLength - circleRadius * 2) / 2;
    double verticalMargin = size.height * 0.05;
    double startY = verticalMargin;

    path.moveTo(startX, startY);

    bool goingRight = true;

    for (int i = 0; i < numberOfStops; i++) {
      if (goingRight) {
        startX += lineLength;
      } else {
        startX -= lineLength;
      }
      path.lineTo(startX, startY);

      Rect arcRect = Rect.fromCircle(
        center: Offset(startX, startY + circleRadius),
        radius: circleRadius,
      );

      if (goingRight) {
        path.arcTo(arcRect, 3 * 3.14159 / 2, 3.14159, false);
      } else {
        path.arcTo(arcRect, -3.14159 / 2, -3.14159, false);
      }

      startY += 2 * circleRadius;
      goingRight = !goingRight;
      
    }

    double totalLength = path.computeMetrics().fold(0, (sum, metric) => sum + metric.length);
    double greenLength = totalLength * progress;
    double coveredLength = 0.0;

    // Draw shadow for the entire path
    canvas.drawPath(path, shadowPaint);

    path.lineTo(startX * (2 * circleRadius), startY);

    if (progress == 1.0) {
      canvas.drawPath(path, greenPaint..color = Color(0xFF99cf2d)); // Full green color
      return;
    }

    // Draw the gradient for the green section
    Shader greenShader = LinearGradient(
      colors: [Color.fromARGB(255, 114, 143, 21), Color.fromARGB(255, 184, 228, 37)], // Gradient from dark to light green
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    greenPaint.shader = greenShader;

    // Draw the green and white parts of the path
    for (PathMetric metric in path.computeMetrics()) {
      if (coveredLength + metric.length < greenLength) {
        canvas.drawPath(metric.extractPath(0, metric.length), greenPaint);
        coveredLength += metric.length;
      } else {
        // Green part
        canvas.drawPath(metric.extractPath(0, greenLength - coveredLength), greenPaint);

        // White part
        canvas.drawPath(metric.extractPath(greenLength - coveredLength, metric.length), whitePaint);
        break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
