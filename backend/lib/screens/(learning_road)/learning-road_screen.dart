// screens/(learning_road)/learning-road_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend/screens/(learning_road)/widgets/animated_dialog.dart';
import 'package:backend/screens/(learning_road)/widgets/progress_and_balance_display.dart';
import 'package:backend/screens/(learning_road)/widgets/road.dart';
import 'package:backend/screens/(learning_road)/widgets/stop_widget.dart';
import 'package:backend/screens/(tips)/tips_screen.dart';
import 'package:backend/theme/app_theme.dart';
import 'package:backend/features/scenarios/buy_now_pay_later_scenario_screen.dart';
import '../../main.dart'; // To access the global routeObserver

class LearningRoadScreen extends StatefulWidget {
  const LearningRoadScreen({Key? key}) : super(key: key);

  @override
  State<LearningRoadScreen> createState() => _LearningRoadScreenState();
}

class _LearningRoadScreenState extends State<LearningRoadScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late SharedPreferences _prefs;
  bool _isLoading = true;

  // Updated stops list with optional 'screen' field
  final List<Map<String, dynamic>> stops = [
    {
      "id": 1,
      "icon": Icons.credit_card,
      "status": "locked",
      "title": "Buy Now, Pay Later",
      "info": "Today's choices impact your finances. Test how you handle payment delays",
      "screen": const BuyNowPayLaterScenarioScreen(),
    },
    {
      "id": 2,
      "icon": Icons.lock,
      "status": "locked",
      "title": "Saving",
      "info": "Learn the importance of saving money and explore strategies to build financial security.",
      "screen": null, // Screen not implemented yet
    },
    {
      "id": 3,
      "icon": Icons.lock,
      "status": "locked",
      "title": "Gambling Basics",
      "info": "Explore the concept of gambling, its risks, and how to maintain responsible habits.",
      "screen": null,
    },
    {
      "id": 4,
      "icon": Icons.lock,
      "status": "locked",
      "title": "Insurances",
      "info": "Understand the purpose of insurance and the basics of different insurance types.",
      "screen": null,
    },
    {
      "id": 5,
      "icon": Icons.lock,
      "status": "locked",
      "title": "Loans",
      "info": "Learn how loans work, their costs, and how to borrow responsibly.",
      "screen": null,
    },
    {
      "id": 6,
      "icon": Icons.lock,
      "status": "locked",
      "title": "Investing",
      "info": "Discover the fundamentals of investing and how to grow wealth over time.",
      "screen": null,
    },
  ];

  int unlockedIndex = 0;
  double initialProgress = 0.0;

  static const Color klooigeldRoze = Color(0xFFF787D9);
  static const Color klooigeldPaars = Color(0xFFC8BBF3);
  static const Color klooigeldBlauw = Color(0xFF1D1999);

  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  late Animation<double> _iconPositionAnimation;
  late Animation<double> _animation;

  final List<Color> unlockedStopColors = [
    klooigeldRoze,
    klooigeldBlauw,
    const Color(0xFF99cf2d),
    klooigeldPaars,
  ];

  final List<IconData> financeIcons = [
    Icons.savings,
    Icons.casino,
    Icons.security,
    Icons.account_balance,
    Icons.trending_up,
  ];

  bool isWhiteToPurple = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  /// Subscribe to the RouteObserver
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  /// Unsubscribe from the RouteObserver to prevent memory leaks
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Called when the current route has been popped back to.
  @override
  void didPopNext() {
    _refreshUnlockedLevels();
  }

  Future<void> _loadProgress() async {
    _prefs = await SharedPreferences.getInstance();
    unlockedIndex = _prefs.getInt('unlockedLevelIndex') ?? 0;

    if (unlockedIndex < 0 || unlockedIndex >= stops.length) {
      unlockedIndex = 0;
    }

    // Unlock icons for levels up to unlockedIndex
    for (int i = 0; i <= unlockedIndex && i < stops.length; i++) {
      stops[i]['status'] = 'unlocked';
      stops[i]['icon'] =
          i == 0 ? Icons.credit_card : financeIcons[(i - 1) % financeIcons.length];
    }

    double initialValue = unlockedIndex / stops.length;
    initialProgress = initialValue;

    _iconPositionAnimation = Tween<double>(
      begin: unlockedIndex / (stops.length - 1),
      end: unlockedIndex / (stops.length - 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _animation = Tween<double>(begin: initialValue, end: initialValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    setState(() {
      _controller.value = initialValue;
      _isLoading = false;
    });
  }

  Future<void> _refreshUnlockedLevels() async {
    // Reload progress from SharedPreferences
    unlockedIndex = _prefs.getInt('unlockedLevelIndex') ?? 0;

    if (unlockedIndex < 0 || unlockedIndex >= stops.length) {
      unlockedIndex = 0;
    }

    // Reset all stops to 'locked'
    for (var stop in stops) {
      stop['status'] = 'locked';
      stop['icon'] = Icons.lock;
    }

    // Unlock stops up to the unlockedIndex
    for (int i = 0; i <= unlockedIndex && i < stops.length; i++) {
      stops[i]['status'] = 'unlocked';
      stops[i]['icon'] =
          i == 0 ? Icons.credit_card : financeIcons[(i - 1) % financeIcons.length];
    }

    double updatedValue = unlockedIndex / stops.length;

    setState(() {
      _iconPositionAnimation = Tween<double>(
        begin: _iconPositionAnimation.value,
        end: unlockedIndex / (stops.length - 1),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _animation = Tween<double>(
        begin: _animation.value,
        end: updatedValue,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.forward(from: 0);
    });
  }

  void _saveProgress() {
    _prefs.setInt('unlockedLevelIndex', unlockedIndex);
  }

  void unlockNextStop() {
    if (unlockedIndex < stops.length - 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToUnlockedLevel(unlockedIndex + 1);
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
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
            unlockedIndex++;
            stops[unlockedIndex]['status'] = 'unlocked';
            stops[unlockedIndex]['icon'] =
                financeIcons[(unlockedIndex - 1) % financeIcons.length];
            _saveProgress();
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
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  /// BNPL TIPS CHECK
  Future<bool> _checkTipsRead() async {
    // "tip_category_progress_0" for BNPL tips
    double progress = _prefs.getDouble('tip_category_progress_0') ?? 0.0;
    if (progress < 1.0) {
      bool? result = await showDialog<bool>(
        context: context,
        builder: (context) => AnimatedDialog(
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
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
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: klooigeldBlauw,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close,
                        color: klooigeldRoze,
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
                      const Icon(
                        Icons.info_outline,
                        size: 50,
                        color: klooigeldBlauw,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "BNPL Tips",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: klooigeldBlauw,
                          fontFamily: AppTheme.neighbor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "You haven't read the tips for Pay Later. Please read them first.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.neighbor,
                          fontWeight: FontWeight.w500,
                          color: klooigeldBlauw,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: klooigeldBlauw,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          "Go to Tips",
                          style: TextStyle(
                            fontFamily: AppTheme.neighbor,
                            color: AppTheme.klooigeldRoze,
                          ),
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
      if (result == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TipsScreen(),
          ),
        );
      }
      return false;
    }
    return true;
  }

  void _showLevelDialog(String title, IconData icon, String info, Widget? screen) async {
    bool isBuyNowPayLaterCompleted = false;

    // Check if BNPL was previously completed
    if (title == "Buy Now, Pay Later") {
      isBuyNowPayLaterCompleted =
          _prefs.getBool('scenario_buynowpaylater_completed') ?? false;
    }

    showDialog(
      context: context,
      builder: (context) => AnimatedDialog(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
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
                    decoration: const BoxDecoration(
                      color: klooigeldBlauw,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: klooigeldRoze,
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
                    const SizedBox(height: 5),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: klooigeldBlauw,
                        fontFamily: AppTheme.neighbor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      info,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.neighbor,
                        fontWeight: FontWeight.w500,
                        color: klooigeldBlauw,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close dialog
                        if (title == "Buy Now, Pay Later") {
                          // If BNPL scenario was completed, user will "PLAY AGAIN" or attempt a single "TRY AGAIN"
                          if (isBuyNowPayLaterCompleted) {
                            // Clear scenario ephemeral progress to start a fresh replay / try again
                            await _clearBuyNowPayLaterProgress();
                          }

                          // Check if BNPL tips have been read
                          bool canProceed = await _checkTipsRead();
                          if (!canProceed) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BuyNowPayLaterScenarioScreen(),
                            ),
                          ).then((result) {
                            // After returning from the scenario screen, refresh unlocked levels
                            if (result == true) {
                              _refreshUnlockedLevels();
                            }
                          });
                        } else if (screen != null) {
                          // Navigate to the associated screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => screen,
                            ),
                          ).then((result) {
                            // After returning from the screen, refresh unlocked levels
                            if (result == true) {
                              _refreshUnlockedLevels();
                            }
                          });
                        } else {
                          // Show level in development overlay
                          _showDevelopmentOverlay();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: klooigeldBlauw,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      // If scenario was completed, display "PLAY AGAIN", else "PLAY"
                      child: Text(
                        title == "Buy Now, Pay Later"
                            ? (isBuyNowPayLaterCompleted ? "PLAY AGAIN" : "PLAY")
                            : "PLAY",
                        style: const TextStyle(
                          fontFamily: AppTheme.neighbor,
                          color: AppTheme.klooigeldRoze,
                        ),
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

  Future<void> _clearBuyNowPayLaterProgress() async {
    // Clear scenario ephemeral progress to start a fresh replay / try again
    await _prefs.remove('scenario_buynowpaylater_chatMessages');
    await _prefs.remove('scenario_buynowpaylater_tempBalance');
    await _prefs.remove('scenario_buynowpaylater_currentStep');
    await _prefs.remove('scenario_buynowpaylater_showNextButton');
    await _prefs.remove('scenario_buynowpaylater_showChoices');
    await _prefs.remove('scenario_buynowpaylater_lastChoiceWasBNPL');
    await _prefs.remove('scenario_buynowpaylater_original_balance');
    await _prefs.remove('scenario_buynowpaylater_accumulated_deductions');
    await _prefs.remove('scenario_buynowpaylater_temp_transactions');
  }

  void _showDevelopmentOverlay() {
    showDialog(
      context: context,
      builder: (context) => AnimatedDialog(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
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
                    decoration: const BoxDecoration(
                      color: klooigeldBlauw,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: klooigeldRoze,
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
                    const Icon(
                      Icons.construction,
                      size: 50,
                      color: klooigeldBlauw,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Level in Development",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: klooigeldBlauw,
                        fontFamily: AppTheme.neighbor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "This level is currently under development. Please check back later!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.neighbor,
                        fontWeight: FontWeight.w500,
                        color: klooigeldBlauw,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: klooigeldBlauw,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          fontFamily: AppTheme.neighbor,
                          color: AppTheme.klooigeldRoze,
                        ),
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
        duration: const Duration(seconds: 2),
        content: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: klooigeldRoze,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: klooigeldBlauw, width: 2),
            ),
            child: const Text(
              "Locked game. Finish previous to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.neighbor,
                fontWeight: FontWeight.bold,
                color: klooigeldBlauw,
                fontSize: 14,
              ),
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 20,
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/learning_road/background_new.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              ProgressAndBalanceDisplay(
                progress: _iconPositionAnimation.value,
                title: 'GAMES',
                onBackPressed: () => Navigator.pop(context),
                onMenuItemSelected: (value) {},
              ),
              Expanded(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double totalHeight = constraints.maxHeight * 2;
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
                                                stops[i]['screen'],
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
                                        child: const Icon(Icons.arrow_forward),
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
