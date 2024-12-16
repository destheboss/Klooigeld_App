// lib/screens/home_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../components/widgets/home/custom_card.dart';
import '../../components/widgets/home/transaction_tile.dart';
import '../../components/widgets/notifications/notification_dropdown.dart';
import '../../theme/app_theme.dart';
import '../../screens/(learning_road)/learning-road_screen.dart';
import '../../screens/(rewards)/rewards_shop_screen.dart';
import '../../screens/(tips)/tips_screen.dart';
import '../../services/notification_service.dart'; // Import NotificationService
import '../../main.dart'; // To access the global routeObserver

/// Simple model matching the JSON structure in RewardsShopScreen
class TransactionRecord {
  final String description;
  final int amount;
  final String date; // Can be YYYY-MM-DD or "Pending"

  TransactionRecord({
    required this.description,
    required this.amount,
    required this.date,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      description: json['description'],
      amount: json['amount'],
      date: json['date'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with RouteAware {
  Future<String>? _usernameFuture;
  Future<int>? _klooicashFuture;
  List<TransactionRecord> _transactions = [];

  final List<String> _subtitles = [
    'FEELING GOOD TODAY?',
    'READY TO EARN MORE?',
    'KEEP UP THE GREAT WORK!',
    'LET’S ACHIEVE SOMETHING NEW!',
    'MAKE TODAY COUNT!',
  ];

  bool _showNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Subscribe to the RouteObserver
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  /// Unsubscribe from the RouteObserver to prevent memory leaks
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Called when the current route has been popped back to.
  @override
  void didPopNext() {
    _refreshData();
  }

  /// Load initial data for username, klooicash, and transactions
  void _loadInitialData() {
    _usernameFuture = _getUsername();
    _klooicashFuture = _getKlooicash();
    _loadTransactions();
  }

  /// Refresh data when returning to HomeScreen
  Future<void> _refreshData() async {
    setState(() {
      _usernameFuture = _getUsername();
      _klooicashFuture = _getKlooicash();
    });
    await _loadTransactions();
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User';
  }

  Future<int> _getKlooicash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('klooicash') ?? 500;
  }

  Future<String?> _getAvatarImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatarImagePath');
  }

  /// Load all permanent transactions from SharedPreferences
  Future<void> _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('user_transactions') ?? [];
    final List<TransactionRecord> loaded = rawList.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return TransactionRecord.fromJson(map);
    }).toList();

    setState(() {
      _transactions = loaded;
    });
  }

  /// Helper method to format the stored date:
  /// If date is "Pending", return "Pending" directly.
  /// Otherwise parse YYYY-MM-DD and format as "Month d".
  String _formatDate(String dateStr) {
    if (dateStr.toLowerCase() == "pending") {
      /// NEW: "Pending" placeholder for Klaro or future-due transactions
      return "Pending";
    }
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat("MMMM d").format(parsed);
    } catch (e) {
      // Fallback if parsing fails
      return dateStr;
    }
  }

  void _toggleNotifications() {
    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  void _closeNotifications() {
    setState(() {
      _showNotifications = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _subtitles.shuffle();
    String randomSubtitle = _subtitles.first;

    double percentage = 1.0; // For demonstration only

    return Scaffold(
      backgroundColor: AppTheme.nearlyWhite,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder(
              future: Future.wait([_usernameFuture!, _klooicashFuture!]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                String username = snapshot.data![0].toString().toUpperCase();
                int klooicash = snapshot.data![1] as int;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26.0, horizontal: 26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Consumer<NotificationService>(
                              builder: (context, notificationService, child) {
                                String iconPath = notificationService.notifications.isNotEmpty
                                    ? 'assets/images/icons/email-notif.png'
                                    : 'assets/images/icons/email.png';
                                return IconButton(
                                  icon: Image.asset(iconPath, width: 40, height: 40),
                                  onPressed: _toggleNotifications,
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            FutureBuilder<String?>(
                              future: _getAvatarImagePath(),
                              builder: (context, snap) {
                                if (snap.hasData && snap.data != null && File(snap.data!).existsSync()) {
                                  return CircleAvatar(
                                    radius: 20,
                                    backgroundImage: FileImage(File(snap.data!)),
                                  );
                                } else {
                                  return const CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage('assets/images/default_user.png'),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Greeting and subtitle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HEY, $username',
                              style: TextStyle(
                                fontFamily: AppTheme.titleFont,
                                fontSize: 42,
                                color: AppTheme.nearlyBlack2,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -8),
                              child: Text(
                                randomSubtitle,
                                style: const TextStyle(
                                  fontFamily: AppTheme.neighbor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppTheme.nearlyBlack2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Main Cards
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Klooicash Balance
                            CustomCard(
                              backgroundColor: AppTheme.klooigeldGroen,
                              shadowColor: Colors.black26,
                              onTap: () {},
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'KLOOICASH',
                                    style: TextStyle(
                                      fontFamily: AppTheme.titleFont,
                                      fontSize: 28,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '$klooicash',
                                        style: const TextStyle(
                                          fontFamily: AppTheme.neighbor,
                                          fontSize: 26,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Transform.translate(
                                        offset: const Offset(0, 0.6),
                                        child: Image.asset(
                                          'assets/images/currency_white.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),
                            // Daily Tasks Card
                            CustomCard(
                              backgroundColor: AppTheme.klooigeldRoze,
                              shadowColor: Colors.black26,
                              onTap: () {},
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.white,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${(percentage * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontFamily: AppTheme.neighbor,
                                              fontSize: 16,
                                              color: AppTheme.klooigeldRoze,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Transform.translate(
                                            offset: const Offset(0, 2),
                                            child: const Text(
                                              'DAILY TASKS',
                                              style: TextStyle(
                                                fontFamily: AppTheme.titleFont,
                                                fontSize: 24,
                                                color: AppTheme.white,
                                              ),
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: const Offset(0, -2),
                                            child: Text(
                                              percentage == 1.0 ? 'ALL TASKS COMPLETED!' : 'YOU HAVE MORE TO GO!',
                                              style: const TextStyle(
                                                fontFamily: AppTheme.neighbor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: AppTheme.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const FaIcon(FontAwesomeIcons.list, size: 28, color: AppTheme.white),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),
                            // Tips Card
                            CustomCard(
                              backgroundColor: AppTheme.klooigeldPaars,
                              shadowColor: Colors.black26,
                              onTap: () async {
                                // When returning from TipsScreen, reload transactions to reflect any changes.
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => const TipsScreen()));
                                _refreshData();
                              },
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'TIPS',
                                    style: TextStyle(
                                      fontFamily: AppTheme.titleFont,
                                      fontSize: 24,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  FaIcon(FontAwesomeIcons.solidLightbulb, size: 28, color: AppTheme.white),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),
                            // KLOOI GAMES and KLOOI SHOP
                            Row(
                              children: [
                                Expanded(
                                  child: CustomCard(
                                    backgroundColor: AppTheme.klooigeldBlauw,
                                    shadowColor: Colors.black26,
                                    onTap: () async {
                                      // Refresh upon returning from the scenario screen
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LearningRoadScreen()),
                                      );
                                      _refreshData();
                                    },
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: const [
                                        FaIcon(FontAwesomeIcons.gamepad, size: 48, color: AppTheme.white),
                                        SizedBox(height: 5),
                                        Text(
                                          'KLOOI\nGAMES',
                                          style: TextStyle(
                                            fontFamily: AppTheme.titleFont,
                                            fontSize: 18,
                                            color: AppTheme.white,
                                            height: 1.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomCard(
                                    backgroundColor: AppTheme.klooigeldGroen,
                                    shadowColor: Colors.black26,
                                    onTap: () async {
                                      // When the user finishes shopping, we want to refresh
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RewardsShopScreen()),
                                      );
                                      _refreshData(); // refresh after shop
                                    },
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: const [
                                        FaIcon(FontAwesomeIcons.bagShopping, size: 48, color: AppTheme.white),
                                        SizedBox(height: 5),
                                        Text(
                                          'KLOOI\nSHOP',
                                          style: TextStyle(
                                            fontFamily: AppTheme.titleFont,
                                            fontSize: 18,
                                            color: AppTheme.white,
                                            height: 1.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),
                            // ACCOUNT
                            CustomCard(
                              backgroundColor: AppTheme.klooigeldPaars,
                              shadowColor: Colors.black26,
                              onTap: () {},
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'ACCOUNT',
                                    style: TextStyle(
                                      fontFamily: AppTheme.titleFont,
                                      fontSize: 24,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  FaIcon(FontAwesomeIcons.solidCircleUser, size: 28, color: AppTheme.white),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            // Transactions Section
                            const Text(
                              'TRANSACTIONS',
                              style: TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: AppTheme.black,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // If no transactions, show a simple note. Otherwise, show the list.
                            if (_transactions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    fontFamily: AppTheme.neighbor,
                                    fontSize: 16,
                                    color: AppTheme.grey,
                                  ),
                                ),
                              )
                            else
                              // Refactored Transaction List with Limited Height and Scrollability
                              SizedBox(
                                // Assuming each TransactionTile has a height of approximately 70 pixels
                                height: _transactions.length > 3 ? 3 * 70.0 + 2 * 1.0 : _transactions.length * 70.0,
                                child: ListView.separated(
                                  physics: _transactions.length > 3
                                      ? const AlwaysScrollableScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                                  itemCount: _transactions.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 0),
                                  itemBuilder: (context, index) {
                                    final tx = _transactions[index];
                                    final sign = tx.amount > 0 ? '+' : (tx.amount < 0 ? '-' : '');
                                    /// If it's a pending Klaro transaction with amount=0,
                                    /// we still show "0 K" to clarify that the real payment is pending.
                                    final formattedAmount = tx.amount != 0 ? '$sign${tx.amount.abs()} K' : '0 K';

                                    return TransactionTile(
                                      description: tx.description,
                                      amount: formattedAmount,
                                      date: _formatDate(tx.date),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Notification Dropdown
            if (_showNotifications)
              NotificationDropdown(
                onClose: _closeNotifications,
              ),
          ],
        ),
      ),
    );
  }
}
