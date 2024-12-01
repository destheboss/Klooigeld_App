import 'dart:ui';
import 'package:backend/screens/(learning_road)/widgets/animated_dialog.dart';
import 'package:backend/screens/(learning_road)/widgets/progress_line_indicator.dart';
import 'package:flutter/material.dart';
class ProgressAndBalanceDisplay extends StatefulWidget {
  final double progress;
  final double userBalance;

  const ProgressAndBalanceDisplay({
    Key? key,
    required this.progress,
    required this.userBalance,
  }) : super(key: key);

  @override
  _ProgressAndBalanceDisplayState createState() =>
      _ProgressAndBalanceDisplayState();
}

class _ProgressAndBalanceDisplayState extends State<ProgressAndBalanceDisplay>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
    static const Color klooigeldBlauw = Color(0xFF1D1999); // New: Button & pop-up background / Button text
  

  void _onTap() {
    setState(() {
      _scale = 1.1;
    });

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _scale = 1.0;
      });
    });

    _showCurrencyExplanationDialog();
  }

  void _showCurrencyExplanationDialog() {
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
                'assets/images/learning_road/klooigeld_container.png',
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
                fit: BoxFit.contain,
              ),
              Positioned(
                top: 110,
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
                      color: Colors.white,
                      size: 25,
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



 @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Background Image
        Image.asset(
          'assets/images/learning_road/top_bar2.png',
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        // Foreground Content
        Positioned(
          top: 75,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Progress Line
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: ProgressLinePainter(progress: widget.progress),
                        child: Container(height: 60), // Adjust height to fit the image
                      ),
                      Positioned.fill(
                        top: 0,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Align(
                              alignment: Alignment(
                                -1.0 + (widget.progress * 2.0),
                                -1,
                              ),
                              child: Icon(
                                Icons.directions_walk,
                                size: 30, // Adjust size to fit better
                                color: klooigeldBlauw,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Klooigeld Display
              GestureDetector(
                onTap: _onTap,
                child: AnimatedScale(
                  scale: _scale,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Make transparent to blend with the background
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                        'assets/symbols/klooigeld_symbol_white.png',
                        width: 25,
                        height: 25,
                        fit: BoxFit.contain,
                      ),
                       // Icon(Icons.monetization_on, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          widget.userBalance.toStringAsFixed(2),
                          style: TextStyle(
                            color: Colors.white, // White text to match the image
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}