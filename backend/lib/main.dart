// main.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import screens
import 'screens/(home)/home_screen.dart';
import 'screens/(introduction)/introduction_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App runs only in portrait mode.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Precache all images before the app starts.
  await precacheAssets();

  // Retrieve shared preferences instance and check introduction screen status.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenIntroduction = prefs.getBool('hasSeenIntroduction') ?? false;

  runApp(KlooigeldApp(hasSeenIntroduction: hasSeenIntroduction));
}

Future<void> precacheAssets() async {
  final String jsonString = await rootBundle.loadString('assets/json/image_list.json');
  final data = json.decode(jsonString);
  final List<String> imagePaths = List<String>.from(data['images']);

  // Create a temporary context for precaching images.
  // Using a dummy widget to obtain a context.
  final Completer<void> completer = Completer<void>();
  runApp(
    MaterialApp(
      home: Builder(
        builder: (context) {
          for (String path in imagePaths) {
            precacheImage(AssetImage(path), context);
          }
          // Once precaching is done, complete the completer.
          completer.complete();
          return const SizedBox(); // Empty widget
        },
      ),
      debugShowCheckedModeBanner: false,
    ),
  );

  // Wait until precaching is complete.
  await completer.future;
  // After precaching, remove the temporary widget by not doing anything.
}

class KlooigeldApp extends StatelessWidget {
  final bool hasSeenIntroduction;

  const KlooigeldApp({super.key, required this.hasSeenIntroduction});

  @override
  Widget build(BuildContext context) {
    // Setting up system UI overlay styles.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      title: 'Klooigeld App',
      navigatorObservers: [routeObserver], // Add the RouteObserver here
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
