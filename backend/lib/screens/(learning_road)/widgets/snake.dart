import 'package:flutter/material.dart';
class RoadmapPainter extends CustomPainter {
  final List<Offset> stopPositions = [];
  final int numberOfStops;

  RoadmapPainter(this.numberOfStops);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    Path path = Path();

    // Parameters
    double lineLength = size.width * 0.4; // Length of the straight lines
    double circleRadius = size.width * 0.20; // Radius of the half-circles
    double startX = circleRadius; // Starting X position adjusted for centering
    double centerOffset = (size.width - lineLength - circleRadius * 2) / 2;
    startX += centerOffset; // Adjust startX to center the path horizontally
    double verticalMargin = size.height * 0.05; // Top margin
    double startY = verticalMargin; // Starting Y position adjusted for margin

    // Move to starting position
    path.moveTo(startX, startY);

    bool goingRight = true;

    // Loop based on the number of stops
    for (int i = 0; i < numberOfStops; i++) {
      // Draw straight line
      if (goingRight) {
        startX += lineLength;
      } else {
        startX -= lineLength;
      }
      path.lineTo(startX, startY);

      // Add a U-turn (half-circle)
      Rect arcRect = Rect.fromCircle(
        center: Offset(startX, startY + circleRadius),
        radius: circleRadius,
      );

      if (goingRight) {
        path.arcTo(arcRect, 3 * 3.14159 / 2, 3.14159, false);
        stopPositions.add(Offset(startX, startY)); // Add stop position
      } else {
        path.arcTo(arcRect, -3.14159 / 2, -3.14159, false);
        stopPositions.add(Offset(startX, startY)); // Add stop position
      }

      // Update position after U-turn
      startY += 2 * circleRadius; // Move vertically down for the next straight line
      goingRight = !goingRight; // Alternate direction
    }

    // Add a final straight line to the next side of the screen
    if (goingRight) {
      startX += lineLength * 2;
    } else {
      startX -= lineLength * 2;
    }
    path.lineTo(startX, startY );

    // Draw the path on the canvas
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

