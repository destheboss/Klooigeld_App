import 'package:backend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FirstView extends StatelessWidget {
  final AnimationController animationController;

  const FirstView({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final firstHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.0,
          0.2,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    final secondHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-1, 0))
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.2,
          0.4,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    final textAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-2, 0))
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.2,
          0.4,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    final imageAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-4, 0))
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.2,
          0.4,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    final relaxAnimation =
        Tween<Offset>(begin: const Offset(0, -2), end: const Offset(0, 0))
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.0,
          0.2,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    return SlideTransition(
      position: firstHalfAnimation,
      child: SlideTransition(
        position: secondHalfAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: relaxAnimation,
                child: const Text(
                  "LEARN BY DOING",
                  style: TextStyle(
                    fontFamily: 'NeighborBlack',
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.klooigeldBlauw),
                ),
              ),
              SlideTransition(
                position: textAnimation,
                child: const Padding(
                  padding:
                      EdgeInsets.only(left: 60, right: 60, top: 10, bottom: 45),
                  child: Text(
                    "TAKE ON REAL-LIFE FINANCIAL SCENARIOS AND MASTER SMART DECISION-MAKING",
                    textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', color: AppTheme.klooigeldBlauw),
                  ),
                ),
              ),
              SlideTransition(
                position: imageAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 350, maxHeight: 250),
                  child: Image.asset(
                    'assets/images/introduction_screen/1_view.png',
                    fit: BoxFit.contain,
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
