import 'package:backend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  final AnimationController animationController;

  const SplashView({super.key, required this.animationController});

  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    final introductionAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0.0, -1.0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(
        0.0,
        0.2,
        curve: Curves.fastOutSlowIn,
      ),
    ));

    return SlideTransition(
      position: introductionAnimation,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/images/introduction_screen/introduction_image.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                "MONEY MADE FUN",
                style: TextStyle(
                    fontFamily: 'NeighborBlack',
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.klooigeldBlauw),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 60, right: 60),
              child: Text(
                "TURN SMART DECISIONS INTO KLOOIGELD CURRENCY AND UNLOCK A WORLD OF REWARDS",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', color: AppTheme.klooigeldBlauw),
              ),
            ),
            const SizedBox(
              height: 65,
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 16),
              child: InkWell(
                onTap: () {
                  widget.animationController.animateTo(0.2);
                },
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.only(
                    left: 56.0,
                    right: 56.0,
                    top: 16,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38.0),
                    color: AppTheme.klooigeldRozeAlt,
                  ),
                  child: const Text(
                    "Let's Start",
                    style: TextStyle(
                      fontFamily: 'NeighborBlack',
                      fontSize: 18,
                      color: AppTheme.klooigeldBlauw,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
