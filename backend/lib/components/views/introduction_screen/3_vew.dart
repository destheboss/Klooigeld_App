import 'package:backend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ThirdView extends StatelessWidget {
  final AnimationController animationController;

  const ThirdView({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final firstHalfAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.4,
        0.6,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final secondHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-1, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.6,
        0.8,
        curve: Curves.fastOutSlowIn,
      ),
    ));

    final moodFirstHalfAnimation =
        Tween<Offset>(begin: const Offset(2, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.4,
        0.6,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final moodSecondHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-2, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.6,
        0.8,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final imageFirstHalfAnimation =
        Tween<Offset>(begin: const Offset(4, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.4,
        0.6,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final imageSecondHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-4, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.6,
        0.8,
        curve: Curves.fastOutSlowIn,
      ),
    ));

    return SlideTransition(
      position: firstHalfAnimation,
      child: SlideTransition(
        position: secondHalfAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const Text(
                  "BUILD GOOD HABITS",
                  style: TextStyle(
                    fontFamily: 'NeighborBlack',
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.klooigeldBlauw),
                ),
              SlideTransition(
                position: moodFirstHalfAnimation,
                child: SlideTransition(
                  position: moodSecondHalfAnimation,
                  child: const Padding(
                    padding:
                      EdgeInsets.only(left: 60, right: 60, top: 10, bottom: 45),
                  child: Text(
                    "LEARN BUDGETING, AVOID PITFALLS, AND GROW YOUR FINANCIAL CONFIDENCE",
                    textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', color: AppTheme.klooigeldBlauw),
                  ),
                  ),
                ),
              ),
              SlideTransition(
                position: imageFirstHalfAnimation,
                child: SlideTransition(
                  position: imageSecondHalfAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 350, maxHeight: 250),
                    child: Image.asset(
                      'assets/images/introduction_screen/3_view.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
