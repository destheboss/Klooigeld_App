import 'dart:math';
import 'dart:ui';
import 'package:backend/screens/(learning_road)/widgets/klooigeld_display.dart';
import 'package:backend/screens/(learning_road)/widgets/snake.dart';
import 'package:backend/screens/(learning_road)/widgets/stop-widget.dart';
import 'package:flutter/material.dart';

class LearningRoadScreen extends StatefulWidget {
  @override
  State<LearningRoadScreen> createState() => _LearningRoadScreenState();
}

class _LearningRoadScreenState extends State<LearningRoadScreen> {
  final List<Map<String, dynamic>> stops = [
    {"id": 1, "icon": Icons.credit_card, "status": "unlocked"},
    {"id": 2, "icon": Icons.monetization_on, "status": "unlocked"},
    {"id": 3, "icon": Icons.lock, "status": "unlocked"},
    {"id": 4, "icon": Icons.lock, "status": "unlocked"},
    {"id": 5, "icon": Icons.lock, "status": "unlocked"},
    {"id": 6, "icon": Icons.lock, "status": "unlocked"},
    {"id": 7, "icon": Icons.lock, "status": "locked"},
    {"id": 8, "icon": Icons.lock, "status": "locked"},
    {"id": 9, "icon": Icons.lock, "status": "locked"},
    {"id": 10, "icon": Icons.lock, "status": "locked"},
  ];

  // Colors for unlocked stops
  final List<Color> unlockedStopColors = [
    Color(0xFFB2DF1F), // Purple
    Color(0xFFF787D9), // Pink
    Color(0xFFC8BBF3), // Dark Blue
    //Color(0xFFB2DF1F), // Purple
  ];

  final double userBalance = 1250.50; 
 // Example user balance
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Games",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC8BBF3), Color(0xFF1D1999)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              double bottomMargin = constraints.maxHeight * 0.3;
              double totalHeight =
                  constraints.maxHeight * 2 + bottomMargin;
              Size size = Size(constraints.maxWidth, totalHeight);

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
                          for (int i = 0; i < stopPositions.length; i++)
                            Positioned(
                              left: stopPositions[i].dx - 30,
                              top: stopPositions[i].dy - 30,
                              child: StopWidget(
                                icon: stops[i]['icon'],
                                status: stops[i]['status'],
                                isActive: stops[i]['status'] == 'unlocked',
                                color: stops[i]['status'] == 'unlocked'
                                    ? unlockedStopColors[i %
                                        unlockedStopColors.length]
                                    : Colors.white.withOpacity(0.8),
                              ),
                            ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              backgroundColor: Color(0xFF1D1999),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Color(0xFFC8BBF3),
                                    title: Text(
                                      "Learning Progress",
                                      style: TextStyle(
                                        color: Color(0xFF000000),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      "Keep going! You have ${stops.where((s) => s['status'] == 'locked').length} stops left to unlock.",
                                      style: TextStyle(color: Color(0xFF000000)),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: Text(
                                          "Close",
                                          style: TextStyle(
                                            color: Color(0xFF1D1999),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Icon(Icons.info, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: KlooigeldDisplay(balance: userBalance),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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