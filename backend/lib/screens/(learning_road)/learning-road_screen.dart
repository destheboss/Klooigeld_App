import 'package:backend/screens/(learning_road)/widgets/animated_dialog.dart';
import 'package:backend/screens/(learning_road)/widgets/progress_and_balance_display.dart';
import 'package:backend/screens/(learning_road)/widgets/road.dart';
import 'package:backend/screens/(learning_road)/widgets/stop-widget.dart';
import 'package:flutter/material.dart';

class LearningRoadScreen extends StatefulWidget {
  @override
  State<LearningRoadScreen> createState() => _LearningRoadScreenState();
}

class _LearningRoadScreenState extends State<LearningRoadScreen> 
with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> stops = [
    {"id": 1, "icon": Icons.credit_card, "status": "unlocked", "title": "Level 1: Introduction to Finance", "info": "Learn about the currencies and how to convert them."},
    {"id": 2, "icon": Icons.monetization_on, "status": "unlocked", "title": "Level 2: Budgeting Basics", "info": "What is a budget and why do I need one when shopping?"},
    {"id": 3, "icon": Icons.lock, "status": "locked", "title": "Level 3: Investing for Beginners", "info": "I have money, so where do I put them?"},
    {"id": 4, "icon": Icons.lock, "status": "locked", "title": "Level 4: Managing Debt", "info": "Understand how to manage loans and pay off debt effectively."},
    {"id": 5, "icon": Icons.lock, "status": "locked", "title": "Level 5: Saving Strategies", "info": "Discover practical ways to save money and grow your savings."},
    {"id": 6, "icon": Icons.lock, "status": "locked", "title": "Level 6: Advanced Investing", "info": "Explore stocks, bonds, and mutual funds to diversify your investments."},
    {"id": 7, "icon": Icons.lock, "status": "locked", "title": "Level 7: Financial Planning", "info": "Learn how to plan for big purchases and set long-term financial goals."},
    {"id": 8, "icon": Icons.lock, "status": "locked", "title": "Level 8: Understanding Taxes", "info": "Find out how taxes work and how they affect your income."},
    { "id": 9,"icon": Icons.lock,"status": "locked","title": "Level 9: Credit Scores Explained","info": "Discover how credit scores are calculated and how to improve yours."},
    {"id": 10,"icon": Icons.lock,"status": "locked", "title": "Level 10: Building Wealth", "info": "Learn strategies to build wealth and secure your financial future."},
  ];
 
  static const Color klooigeldRoze = Color(0xFFF787D9); // New: Accent style 1 / Card style 1
  static const Color klooigeldGroen = Color(0xFFB2DF1F); // New: Background 1 / Accent style 2 / Card style 2
  static const Color klooigeldDarkGroen = Color(0xFF7D9D16);
  static const Color klooigeldPaars = Color(0xFFC8BBF3); // New: Accent style 2 / Card style 3
  static const Color klooigeldBlauw = Color(0xFF1D1999); // New: Button & pop-up background / Button text

  final double userBalance = 1250.50; 
  bool isWhiteToPurple  = false;
  int unlockedIndex = 0;
  double initialProgress = 0.0;
  
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _iconPositionAnimation;
  late Animation<double> _animation;

  final List<Color> unlockedStopColors = [
    Color(0xFF99cf2d), // Green
    klooigeldRoze, // Pink
    klooigeldBlauw, // Dark Blue
    klooigeldPaars, // Purple
  ];
  final List<IconData> financeIcons = [
    Icons.attach_money,
    Icons.account_balance,
    Icons.savings,
    Icons.pie_chart,
    Icons.trending_up,
    Icons.credit_card,
  ];

  

  @override
  void initState() {
    super.initState();

    // Determine the last unlocked stop
    unlockedIndex = stops.lastIndexWhere((stop) => stop['status'] == 'unlocked');

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _updateBackgroundAnimation();

      // Initialize icon animation
    _iconPositionAnimation = Tween<double>(
      begin: unlockedIndex / (stops.length - 1),
      end: unlockedIndex / (stops.length - 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    double initialProgress = (unlockedIndex  )/ stops.length ;
      _animation = Tween<double>(begin: initialProgress, end: initialProgress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );


    _controller.value = initialProgress;

    _controller.addListener(() {
      setState(() {});
    });
  }

  void _updateBackgroundAnimation() {
  if (isWhiteToPurple) {
    _backgroundAnimation = ColorTween(
      begin: klooigeldPaars, 
      end: klooigeldBlauw,  
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  } else {
    _backgroundAnimation = ColorTween(
      begin: klooigeldBlauw,
      end: klooigeldPaars, 
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
}


  void unlockNextStop() {
  if (unlockedIndex < stops.length - 1) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUnlockedLevel(unlockedIndex + 1);
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        isWhiteToPurple = !isWhiteToPurple;
        _updateBackgroundAnimation();

        double startPosition = unlockedIndex / (stops.length - 1);
        double endPosition = (unlockedIndex + 1) / (stops.length - 1);

        _iconPositionAnimation = Tween<double>(
          begin: startPosition,
          end: endPosition,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

        double startProgress = unlockedIndex / stops.length;
        double endProgress = (unlockedIndex + 1) / stops.length;
        _animation = Tween<double>(begin: startProgress, end: endProgress)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      });

      _controller.forward(from: 0).then((_) {
        setState(() {
          stops[unlockedIndex + 1]['status'] = 'unlocked';
          stops[unlockedIndex + 1]['icon'] =
              financeIcons[unlockedIndex % financeIcons.length];
          unlockedIndex++;
        });
      });
    });
  }
}

void _scrollToUnlockedLevel(int index) {
  final itemHeight = 150.0;
  final screenHeight = MediaQuery.of(context).size.height;

  final targetScrollPosition =
      (itemHeight * index) - (screenHeight / 2 - itemHeight / 2);

  _scrollController.animateTo(
    targetScrollPosition.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    ),
    duration: Duration(milliseconds: 700),
    curve: Curves.easeInOut,
  );
}



  void _showLevelDialog(String title, IconData icon, String info) {
  showDialog(
    context: context,
    builder: (context) => AnimatedDialog(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Image
            Image.asset(
              'assets/images/learning_road/level_info_container.png',
              width: MediaQuery.of(context).size.width * 0.95, 
              fit: BoxFit.contain,
            ),
            // Content Overlay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Icon(
                    icon,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Info
                  Text(
                    info,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "Play",
                      style: TextStyle(color: klooigeldBlauw),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("This level is locked. Unlock previous levels to access."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                _backgroundAnimation.value ?? klooigeldPaars!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        Column(
          children: [
            // Top Display
            Container(
              color: Colors.white,
              child: ProgressAndBalanceDisplay(
                progress: _iconPositionAnimation.value,
                userBalance: userBalance,
              ),
            ),

            // Learning Road
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          _backgroundAnimation.value ?? klooigeldPaars!,
                        ],
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

                      RoadmapPainter roadmapPainter =
                          RoadmapPainter(stops.length, _animation.value);
                      roadmapPainter.calculateStopPositions(size);
                      List<Offset> stopPositions = roadmapPainter.stopPositions;

                      return Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _scrollController,
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
                                      child: GestureDetector(
                                        onTap: () {
                                          if (stops[i]['status'] == 'unlocked') {
                                            _showLevelDialog(
                                              stops[i]['title'],
                                              stops[i]['icon'],
                                              stops[i]['info'],
                                            );
                                          } else {
                                            _showLockedMessage();
                                          }
                                        },
                                        child: StopWidget(
                                          icon: stops[i]['icon'],
                                          status: stops[i]['status'],
                                          isActive: stops[i]['status'] ==
                                              'unlocked',
                                          isCurrent: i == unlockedIndex,
                                          color: stops[i]['status'] == 'unlocked'
                                              ? unlockedStopColors[
                                                  i % unlockedStopColors.length]
                                              : Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    right: 16,
                                    bottom: 16,
                                    child: FloatingActionButton(
                                      backgroundColor: klooigeldBlauw,
                                      onPressed: unlockNextStop,
                                      child: Icon(Icons.arrow_forward),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}