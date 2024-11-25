import 'package:backend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SecondView extends StatelessWidget {
  final AnimationController animationController;

  const SecondView({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final firstHalfAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.2,
        0.4,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final secondHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-1, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.4,
        0.6,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final relaxFirstHalfAnimation =
        Tween<Offset>(begin: const Offset(2, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.2,
        0.4,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final relaxSecondHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-2, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.4,
        0.6,
        curve: Curves.fastOutSlowIn,
      ),
    ));

    final imageFirstHalfAnimation =
        Tween<Offset>(begin: const Offset(4, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.2,
        0.4,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final imageSecondHalfAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(-4, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.4,
        0.6,
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
              SlideTransition(
                position: imageFirstHalfAnimation,
                child: SlideTransition(
                  position: imageSecondHalfAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 350, maxHeight: 250),
                    child: Image.asset(
                      'assets/images/introduction_screen/2_view.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(
              height: 45,
            ),
              SlideTransition(
                position: relaxFirstHalfAnimation,
                child: SlideTransition(
                  position: relaxSecondHalfAnimation,
                child: const Text(
                  "REWARD YOUR PROGRESS",
                  style: TextStyle(
                    fontFamily: 'NeighborBlack',
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.klooigeldBlauw),
                ),
                ),
              ),
              const Padding(
                padding:
                      EdgeInsets.only(left: 60, right: 60, top: 10, bottom: 10),
                  child: Text(
                    "SAVE KLOOIGELD TO UNLOCK BADGES, MILESTONES, AND EXCLUSIVE UPGRADES",
                    textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', color: AppTheme.klooigeldBlauw),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
