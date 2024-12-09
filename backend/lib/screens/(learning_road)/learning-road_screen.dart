import 'package:backend/screens/(learning_road)/widgets/animated_dialog.dart';
import 'package:backend/screens/(learning_road)/widgets/progress_and_balance_display.dart';
import 'package:backend/screens/(learning_road)/widgets/road.dart';
import 'package:backend/screens/(learning_road)/widgets/stop-widget.dart';
import 'package:backend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LearningRoadScreen extends StatefulWidget {
  @override
  State<LearningRoadScreen> createState() => _LearningRoadScreenState();
}

class _LearningRoadScreenState extends State<LearningRoadScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> stops = [
{"id": 1, "icon": Icons.credit_card, "status": "unlocked", "title": "Buy Now, Pay Later", "info": "Understand how Buy Now, Pay Later services work and their impact on personal finances."},
{"id": 2, "icon": Icons.lock, "status": "locked", "title": "Saving", "info": "Learn the importance of saving money and explore strategies to build financial security."},
{"id": 3, "icon": Icons.lock, "status": "locked", "title": "Gambling Basics", "info": "Explore the concept of gambling, its risks, and how to maintain responsible habits."},
{"id": 4, "icon": Icons.lock, "status": "locked", "title": "Insurances", "info": "Understand the purpose of insurance and the basics of different insurance types."},
{"id": 5, "icon": Icons.lock, "status": "locked", "title": "Loans", "info": "Learn how loans work, their costs, and how to borrow responsibly."},
{"id": 6, "icon": Icons.lock, "status": "locked", "title": "Investing", "info": "Discover the fundamentals of investing and how to grow wealth over time."}

  ];

  static const Color klooigeldRoze = Color(0xFFF787D9);
  static const Color klooigeldPaars = Color(0xFFC8BBF3);
  static const Color klooigeldBlauw = Color(0xFF1D1999);

  final double userBalance = 1250.50;
  bool isWhiteToPurple = false;
  int unlockedIndex = 0;
  double initialProgress = 0.0;

  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  late Animation<double> _iconPositionAnimation;
  late Animation<double> _animation;

  final List<Color> unlockedStopColors = [
    klooigeldRoze,
    klooigeldBlauw,
    Color(0xFF99cf2d),
    klooigeldPaars,
  ];

  final List<IconData> financeIcons = [
    Icons.savings,
    Icons.casino,
    Icons.security,
    Icons.account_balance,
    Icons.trending_up,
  ];

  @override
  void initState() {
    super.initState();
    unlockedIndex = stops.lastIndexWhere((stop) => stop['status'] == 'unlocked');
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _iconPositionAnimation = Tween<double>(
      begin: unlockedIndex / (stops.length - 1),
      end: unlockedIndex / (stops.length - 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    double initialProgress = (unlockedIndex) / stops.length;
    _animation = Tween<double>(begin: initialProgress, end: initialProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.value = initialProgress;

    _controller.addListener(() {
      setState(() {});
    });
  }

  void unlockNextStop() {
    if (unlockedIndex < stops.length - 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToUnlockedLevel(unlockedIndex + 1);
      });

      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          isWhiteToPurple = !isWhiteToPurple;

          double startPosition = unlockedIndex / (stops.length - 1);
          double endPosition = (unlockedIndex + 1) / (stops.length - 1);

          _iconPositionAnimation = Tween<double>(
            begin: startPosition,
            end: endPosition,
          ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

          double startProgress = unlockedIndex / stops.length;
          double endProgress = (unlockedIndex + 1) / stops.length;

          if (unlockedIndex + 1 == stops.length) {
            endProgress = 1.0;
          }
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
              Image.asset(
                'assets/images/learning_road/level_info_container.png',
                width: MediaQuery.of(context).size.width * 0.95,
                fit: BoxFit.contain,
              ),
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: klooigeldBlauw,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      color: AppTheme.klooigeldRoze,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 50,
                      color: klooigeldBlauw,
                    ),
                    SizedBox(height: 5),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: klooigeldBlauw,
                        fontFamily: AppTheme.neighbor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      info,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.neighbor,
                        fontWeight: FontWeight.w500,
                        color: klooigeldBlauw,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: klooigeldBlauw,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        "PLAY",
                        style: TextStyle(fontFamily: AppTheme.neighbor, color: AppTheme.klooigeldRoze),
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
  ScaffoldMessenger.of(context).removeCurrentSnackBar(); 
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: Duration(seconds: 2),
      content: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: klooigeldRoze,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: klooigeldBlauw, width: 2), 
          ),
          child: Text(
            "Locked game. Finish previous to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'neighbor',
              fontWeight: FontWeight.bold,
              color: klooigeldBlauw,
              fontSize: 14,
            ),
          ),
        ),
      ),
      behavior: SnackBarBehavior.floating, // Floating at the bottom
      margin: EdgeInsets.only(
        bottom: 20, // Space above bottom edge
        left: 16,
        right: 16,
      ),
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
          // Keep original background
          Positioned.fill(
            child: Image.asset(
              'assets/images/learning_road/background_new.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // Header & Progress are now handled by ProgressAndBalanceDisplay
              ProgressAndBalanceDisplay(
                progress: _iconPositionAnimation.value,
                
                title: 'GAMES',
                onBackPressed: () => Navigator.pop(context),
                onMenuItemSelected: (value) {
                  // Handle menu selection if needed
                },
              ),
              
              
              // Learning Road
              Expanded(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double bottomMargin = 0;
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
                                            isActive: stops[i]['status'] == 'unlocked',
                                            isCurrent: i == unlockedIndex,
                                            color: stops[i]['status'] == 'unlocked'
                                                ? unlockedStopColors[i % unlockedStopColors.length]
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
                                  height: 30,
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
