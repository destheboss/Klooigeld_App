import 'dart:math';
import 'dart:ui';
import 'package:backend/screens/(learning_road)/widgets/snake.dart';
import 'package:backend/screens/(learning_road)/widgets/stop-widget.dart';
import 'package:flutter/material.dart';

class LearningRoadScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stops = [
    {"id": 1, "icon": Icons.credit_card, "status": "unlocked"},
    {"id": 2, "icon": Icons.monetization_on, "status": "locked"},
    {"id": 3, "icon": Icons.lock, "status": "locked"},
    {"id": 4, "icon": Icons.lock, "status": "locked"},
    {"id": 5, "icon": Icons.lock, "status": "locked"},
    {"id": 6, "icon": Icons.lock, "status": "locked"},
    {"id": 7, "icon": Icons.lock, "status": "locked"},
    {"id": 8, "icon": Icons.lock, "status": "locked"},
    {"id": 9, "icon": Icons.lock, "status": "locked"},
    {"id": 10, "icon": Icons.lock, "status": "locked"},
  ];

  // Colors
  static const Color unlockedColor = Color(0xFFF787D9); // Pink for unlocked stops
  static const Color lockedColor = Color(0xFF7D9D16); // Dark green for locked stops
  static const Color iconColor = Colors.white;
  static const Color appBarColor = Color(0xFF1D1999); // Blue for AppBar
  static const Color textColor = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Learning Road",
          style: TextStyle(color: textColor),
        ),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      backgroundColor: Colors.white, // Keep background white
      body: LayoutBuilder(
        builder: (context, constraints) {
          double bottomMargin = constraints.maxHeight * 0.3; // Bottom margin
          double totalHeight =
              constraints.maxHeight * 2 + bottomMargin; // Include bottom margin
          Size size = Size(constraints.maxWidth, totalHeight);

          // Initialize RoadmapPainter with the number of stops
          RoadmapPainter roadmapPainter = RoadmapPainter(stops.length);
          roadmapPainter.paint(Canvas(PictureRecorder()), size);

          List<Offset> stopPositions = roadmapPainter.stopPositions;

          return Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: size,
                        painter: roadmapPainter,
                      ),
                      // Place stops dynamically
                      for (int i = 0; i < stopPositions.length; i++)
                        Positioned(
                          left: stopPositions[i].dx - 30,
                          top: stopPositions[i].dy - 30,
                          child: StopWidget(
                            icon: stops[i % stops.length]['icon'],
                            status: stops[i % stops.length]['status'],
                            isActive: stops[i % stops.length]['status'] ==
                                'unlocked',
                          ),
                        ),
                      // Add a floating action button for progress details
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          backgroundColor: appBarColor,
                          onPressed: () {
                            // Show progress details
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Learning Progress"),
                                content: Text(
                                  "Keep going! You have ${stops.where((s) => s['status'] == 'locked').length} stops left to unlock.",
                                  style: TextStyle(color: textColor),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Close", style: TextStyle(color: appBarColor)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Icon(Icons.info, color: iconColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


List<Offset> calculateEdgeStops(Size size, int numberOfStops) {
  List<Offset> edgeStops = [];
  double amplitude = size.width / 2.5;
  double wavelength = size.height / 6;
  double minDistance = size.height / (numberOfStops * 2); // Minimum vertical spacing

  Offset? lastAddedStop;

  for (double y = 0; y <= size.height; y += size.height / (numberOfStops * 10)) {
    double x = size.width / 2 + amplitude * sin(2 * pi * y / wavelength);

    // Check for edges and ensure stops are sufficiently spaced
    if ((x - size.width / 2).abs() >= amplitude * 0.8) {
      Offset newStop = Offset(x, y);

      if (lastAddedStop == null || (newStop - lastAddedStop).distance > minDistance) {
        edgeStops.add(newStop);
        lastAddedStop = newStop;

        // Break once we have the required number of stops
        if (edgeStops.length >= numberOfStops) break;
      }
    }
  }
  return edgeStops;
}
