import 'package:flutter/material.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introduction Screen'),
      ),
      body: const Center(
        child: Text('Welcome to the Introduction Screen!'),
      ),
    );
  }
}
