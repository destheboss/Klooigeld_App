import 'dart:ui';
import 'package:backend/screens/(account)/account_screen.dart';
import 'package:backend/screens/(learning_road)/widgets/animated_dialog.dart';
import 'package:backend/screens/(learning_road)/widgets/progress_line_indicator.dart';
import 'package:backend/screens/(tips)/tips_screen.dart';
import 'package:flutter/material.dart';
import 'package:backend/theme/app_theme.dart'; // Ensure this is accessible
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For the icons in the popup menu

class ProgressAndBalanceDisplay extends StatefulWidget {
  final double progress;
  final VoidCallback onBackPressed;      // Add a callback for the back button
  final Function(int)? onMenuItemSelected; // Add a callback for the popup menu actions
  final String title; // To allow a customizable title

  const ProgressAndBalanceDisplay({
    Key? key,
    required this.progress,
    required this.onBackPressed,
    required this.title,
    this.onMenuItemSelected,
  }) : super(key: key);

  @override
  _ProgressAndBalanceDisplayState createState() =>
      _ProgressAndBalanceDisplayState();
}

class _ProgressAndBalanceDisplayState extends State<ProgressAndBalanceDisplay>
    with SingleTickerProviderStateMixin {
  static const Color klooigeldBlauw = Color(0xFF1D1999);

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
    return Container(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background Image behind both header and progress
          Image.asset(
            'assets/images/learning_road/top_bar2.png',
            width: MediaQuery.of(context).size.width,
            height: 260,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: widget.onBackPressed,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.klooigeldBlauw,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.klooigeldBlauw, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(52, 0, 0, 0),
                                offset: Offset(3, 0),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            size: 30,
                            color: AppTheme.klooigeldRoze,
                          ),
                        ),
                      ),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: AppTheme.titleFont,
                          fontSize: 56,
                          color: AppTheme.klooigeldBlauw,
                        ),
                      ),
                      PopupMenuButton<int>(
                        onSelected: (value) {
                          if (widget.onMenuItemSelected != null) {
                            widget.onMenuItemSelected!(value);
                          }
                          if (value == 1) {
                            // Navigate to Account Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AccountScreen()),
                            );
                          } else if (value == 2) {
                            // Navigate to Tips Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TipsScreen()),
                            );
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppTheme.klooigeldBlauw, width: 2),
                        ),
                        color: AppTheme.white,
                        elevation: 4,
                        itemBuilder: (context) => [
                          PopupMenuItem<int>(
                            value: 1,
                            child: Row(
                              children: [
                                const SizedBox(width: 4),
                                Text(
                                  'Account',
                                  style: TextStyle(
                                    fontFamily: AppTheme.neighbor,
                                    fontSize: 14,
                                    color: AppTheme.klooigeldBlauw,
                                  ),
                                ),
                                const Spacer(),
                                const FaIcon(FontAwesomeIcons.user, size: 16, color: AppTheme.klooigeldBlauw),
                              ],
                            ),
                          ),
                          PopupMenuItem<int>(
                            value: 2,
                            child: Row(
                              children: [
                                const SizedBox(width: 4),
                                Text(
                                  'Tips',
                                  style: TextStyle(
                                    fontFamily: AppTheme.neighbor,
                                    fontSize: 14,
                                    color: AppTheme.klooigeldBlauw,
                                  ),
                                ),
                                const Spacer(),
                                const FaIcon(FontAwesomeIcons.lightbulb, size: 16, color: AppTheme.klooigeldBlauw),
                              ],
                            ),
                          ),
                        ],
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.klooigeldBlauw,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.klooigeldBlauw, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(52, 0, 0, 0),
                                  offset: Offset(-3, 0),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: AppTheme.klooigeldRoze,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Only the progress bar, no currency
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                painter: ProgressLinePainter(progress: widget.progress),
                                child: Container(height: 60),
                              ),
                              // Move the human slightly up by adjusting the alignment's Y value
                              Positioned.fill(
                                top: 0,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Align(
                                      alignment: Alignment(
                                        -1.0 + (widget.progress * 2.0),
                                        -1.6, // Adjusted from -1 to -1.2 to move upward
                                      ),
                                      child: Icon(
                                        Icons.directions_walk,
                                        size: 30,
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
