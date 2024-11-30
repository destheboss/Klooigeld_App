import 'package:backend/screens/(financial_scenario)/financial-scenario_screen.dart';
import 'package:flutter/material.dart';

class FinancialTipsLayout extends StatefulWidget {
  @override
  _FinancialTipsLayoutState createState() =>
      _FinancialTipsLayoutState();
}

class _FinancialTipsLayoutState extends State<FinancialTipsLayout> {
  int _currentIndex = 0; // Tracks which card is currently active.
  final Set<int> _clickedCards = {}; // Tracks clicked card indices.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finance Screen',
          style: TextStyle(
            fontFamily: 'NeighborBlack', // TITLES FONT
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          height: 700, // Adjust height for taller layout
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(3, (index) => _buildCard(index)),
          ),
        ),
      ),
      bottomNavigationBar: _clickedCards.length == 3 // Show "Next" only when all cards are clicked
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FinancialScenarioLayout(),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Next'),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      )
          : null, // Hide the button if not all cards are clicked
    );
  }

  Widget _buildCard(int index) {
    final List<Color> cardColors = [
      const Color.fromRGBO(247, 135, 217, 1),
      Color.fromRGBO(178, 223, 31, 1),
      Color.fromRGBO(200, 187, 243, 1)
    ];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 50.0 * index, // Increased spacing between cards
      left: 40 + (3 - index) * 10, // Adjusted left padding
      right: 40 + (3 - index) * 10, // Adjusted right padding
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index; // Highlight tapped card.
            _clickedCards.add(index); // Mark this card as clicked.
          });
          _openAnimatedOverlay(context, index); // Open animated overlay.
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 400,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
              bottom: Radius.circular(25),
            ),
            child: ClipPath(
              clipper: TaperedBottomClipper(),
              child: Container(
                color: cardColors[index % cardColors.length],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Card ${index + 1}', // Card text
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Opens an animated overlay with custom animation
  void _openAnimatedOverlay(BuildContext context, int index) {
    final List<Color> cardColors = [
      const Color.fromRGBO(247, 135, 217, 1),
      Color.fromRGBO(178, 223, 31, 1),
      Color.fromRGBO(200, 187, 243, 1)
    ];

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1), // Start from the bottom
              end: Offset.zero, // Move to the center
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        color: cardColors[index % cardColors.length],
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 40), // Leave space for the close button
                            Text(
                              'Card ${index + 1} Details',
                              style: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Here you can add detailed information about the selected card.',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Close the overlay
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom clipper for tapered bottom shape
class TaperedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0); // Top-left corner
    path.lineTo(size.width, 0); // Top-right corner
    path.lineTo(size.width * 0.85, size.height); // Bottom-right corner (85% width)
    path.lineTo(size.width * 0.15, size.height); // Bottom-left corner (15% width)
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
