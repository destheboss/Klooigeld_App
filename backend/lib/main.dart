// lib/main.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'screens/(home)/home_screen.dart';
import 'screens/(introduction)/introduction_screen.dart';
import 'services/notification_service.dart'; // Import the notification service

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App runs only in portrait mode.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationService(),
      child: const KlooigeldApp(),
    ),
  );
}

class KlooigeldApp extends StatelessWidget {
  const KlooigeldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klooigeld App',
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PrecacheAndLoadScreen(),
    );
  }
}

class PrecacheAndLoadScreen extends StatefulWidget {
  const PrecacheAndLoadScreen({Key? key}) : super(key: key);

  @override
  _PrecacheAndLoadScreenState createState() => _PrecacheAndLoadScreenState();
}

class _PrecacheAndLoadScreenState extends State<PrecacheAndLoadScreen> {
  bool _isLoading = true;
  bool _hasSeenIntroduction = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Precache assets
    await _precacheAssets();

    // Load shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _hasSeenIntroduction = prefs.getBool('hasSeenIntroduction') ?? false;

    // Mock notifications for demonstration if no notifications exist
    NotificationService notificationService = Provider.of<NotificationService>(context, listen: false);
    if (notificationService.notifications.isEmpty) {
      await notificationService.mockNotifications();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _precacheAssets() async {
    final String jsonString = await rootBundle.loadString('assets/json/image_list.json');
    final data = json.decode(jsonString);
    final List<String> imagePaths = List<String>.from(data['images']);

    // Precache images
    await precacheImages(imagePaths);
  }

  Future<void> precacheImages(List<String> imagePaths) async {
    final Completer<void> completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (String path in imagePaths) {
        precacheImage(AssetImage(path), context);
      }
      completer.complete();
    });
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return _hasSeenIntroduction
          ? const HomeScreen()
          : const IntroductionScreen();
    }
  }
}
