import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import screens
import 'screens/(home)/home_screen.dart';
import 'screens/(introduction)/introduction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App runs only in portrait mode.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Precache all images before the app starts.
  await precacheAssets();

  // Retrieve shared preferences instance and check introduction screen status.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenIntroduction = prefs.getBool('hasSeenIntroduction') ?? false;

  runApp(SleepApp(hasSeenIntroduction: hasSeenIntroduction));
}

Future<void> precacheAssets() async {
  final String jsonString = await rootBundle.loadString('assets/json/image_list.json');
  final data = json.decode(jsonString);
  final List<String> imagePaths = List<String>.from(data['images']);

  final Widget tempWidget = MaterialApp(
    builder: (context, child) {
      for (String path in imagePaths) {
        precacheImage(AssetImage(path), context);
      }
      return const SizedBox();
    },
  );

  runApp(tempWidget);
}

class SleepApp extends StatelessWidget {
  final bool hasSeenIntroduction;

  const SleepApp({super.key, required this.hasSeenIntroduction});

  @override
  Widget build(BuildContext context) {
    // Setting up system UI overlay styles.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      title: 'Klooigeld App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: hasSeenIntroduction
          ? const HomeScreen()
          : const IntroductionScreen(),
    );
  }
}
