import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen',
          style: TextStyle(
            fontFamily: 'NeighborBlack', // TITLES FONT
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Klooigeld',
              style: TextStyle(
                fontFamily: 'PurpleMagicSVG', // LOGO FONT 1
                fontSize: 80,
              ),
            ),
            const Text(
              'Klooigeld',
              style: TextStyle(
                fontFamily: 'PurpleMagic', // LOGO FONT 2
                fontSize: 80,
              ),
            ),
            const Text(
              'Klooigeld',
              style: TextStyle(
                fontFamily: 'NeighborBlack', // TITLE FONT
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Klooigeld',
              style: TextStyle(
                fontFamily: 'Poppins', // TEXT FONT
                fontSize: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
