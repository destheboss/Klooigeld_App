import 'dart:convert';
import 'dart:io';
import 'package:backend/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Use updated import for the new InfoOverlay
import '../../components/widgets/overlays/info_overlay.dart'; // Overlay that shows app info

import '../../components/widgets/home/custom_card.dart';
import '../../components/widgets/home/transaction_tile.dart';
import '../../components/widgets/notifications/notification_dropdown.dart';
import '../../components/widgets/daily_tasks/daily_task_overlay.dart'; // Daily task overlay
import '../../components/widgets/daily_tasks/daily_task_card.dart';   // Daily task card
import '../../theme/app_theme.dart';
import '../../screens/(learning_road)/learning-road_screen.dart';
import '../../screens/(rewards)/rewards_shop_screen.dart';
import '../../screens/(tips)/tips_screen.dart';
import '../../screens/(account)/account_screen.dart';
import '../../services/notification_service.dart'; // NotificationService
import '../../services/daily_task_service.dart';    // DailyTaskService
import '../../services/transaction_service.dart';

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
  bool _showDailyTasksOverlay = false;

  /// Controls the info overlay that displays app credits
  bool _showInfoOverlay = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Subscribe to the RouteObserver and DailyTaskService
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    // Subscribe to DailyTaskService changes
    final taskService = Provider.of<DailyTaskService>(context);
    taskService.addListener(_onTaskServiceChanged);
  }

  /// Unsubscribe from the RouteObserver and DailyTaskService to prevent memory leaks
  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    // Unsubscribe from DailyTaskService
    final taskService = Provider.of<DailyTaskService>(context, listen: false);
    taskService.removeListener(_onTaskServiceChanged);

    super.dispose();
  }

  /// Called when the current route has been popped back to.
  @override
  void didPopNext() {
    _refreshData();
  }

  /// Listener for DailyTaskService changes
  void _onTaskServiceChanged() {
    _refreshData();
  }

  /// Load initial data for username, klooicash, and transactions
  void _loadInitialData() {
    _usernameFuture = _getUsername();
    _klooicashFuture = _getKlooicash();
    _loadTransactions();
  }

  /// Refresh data when returning to HomeScreen or when tasks change
  Future<void> _refreshData() async {
    setState(() {
      _usernameFuture = _getUsername();
      _klooicashFuture = _getKlooicash();
    });
    await _loadTransactions();
    final newBalance = await _klooicashFuture!;
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    await notificationService.checkBalanceWarnings(newBalance);
  }

  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User';
  }

  Future<int> _getKlooicash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('klooicash') ?? 500;
  }

  Future<String?> _getAvatarImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatarImagePath');
  }

  /// Load all permanent transactions from SharedPreferences
  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('user_transactions') ?? [];
    final List<TransactionRecord> loaded = rawList.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return TransactionRecord.fromJson(map);
    }).toList();

    setState(() {
      _transactions = loaded;
    });
  }

  /// Helper to format date:
  /// If date is "Pending", return "Pending".
  /// Otherwise parse YYYY-MM-DD and format as "Month d".
  String _formatDate(String dateStr) {
    if (dateStr.toLowerCase() == "pending") {
      return "Pending";
    }
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat("MMMM d").format(parsed);
    } catch (e) {
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

  void _toggleDailyTasksOverlay() {
    setState(() {
      _showDailyTasksOverlay = !_showDailyTasksOverlay;
    });
  }

  /// Toggles the info overlay
  void _toggleInfoOverlay() {
    setState(() {
      _showInfoOverlay = !_showInfoOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    _subtitles.shuffle();
    final randomSubtitle = _subtitles.first;

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

                final username = snapshot.data![0].toString().toUpperCase();
                final klooicash = snapshot.data![1] as int;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ICONS ROW


                        Row(
                          children: [
                            // Info icon (aligned above the "H" in the title)
                            Transform.translate(
                              offset: const Offset(-9, 0), // Adjust X and Y offsets to position the icon
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/icons/terminal-solid.svg',
                                  width: 22,
                                  height: 22,
                                ),
                                onPressed: _toggleInfoOverlay,
                              ),
                            ),


                            // Spacer to push the other icons to the right
                            const Spacer(),

                            // Notification icon
                            Consumer<NotificationService>(
                              builder: (context, notificationService, child) {
                                final iconPath = notificationService.notifications.isNotEmpty
                                    ? 'assets/images/icons/email-notif.png'
                                    : 'assets/images/icons/email.png';
                                return IconButton(
                                  icon: Image.asset(iconPath, width: 40, height: 40),
                                  onPressed: _toggleNotifications,
                                );
                              },
                            ),
                            const SizedBox(width: 4),

                            // Avatar
                            FutureBuilder<String?>(
                              future: _getAvatarImagePath(),
                              builder: (context, snap) {
                                if (snap.hasData &&
                                    snap.data != null &&
                                    File(snap.data!).existsSync()) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AccountScreen()),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: FileImage(File(snap.data!)),
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AccountScreen()),
                                      );
                                    },
                                    child: const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage('assets/images/default_user.png'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        /// GREETING AND SUBTITLE
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

                        /// MAIN CARDS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// KLOOICASH BALANCE
                            CustomCard(
                              backgroundColor: AppTheme.klooigeldGroen,
                              shadowColor: Colors.black26,
                              onTap: () {},
                              padding: const EdgeInsets.all(16),
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

                            /// DAILY TASKS CARD
                            Consumer<DailyTaskService>(
                              builder: (context, taskService, child) {
                                final percentage = taskService.completionPercentage;
                                final percentageText = '${(percentage * 100).toInt()}%';

                                return CustomCard(
                                  backgroundColor: AppTheme.klooigeldRoze,
                                  shadowColor: Colors.black26,
                                  onTap: _toggleDailyTasksOverlay,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppTheme.white, width: 2),
                                              color: AppTheme.white,
                                            ),
                                            child: Center(
                                              child: Text(
                                                percentageText,
                                                style: TextStyle(
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
                                                  percentage == 1.0
                                                      ? 'ALL TASKS COMPLETED!'
                                                      : 'YOU HAVE MORE TO GO!',
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
                                );
                              },
                            ),
                            const SizedBox(height: 18),

                            /// TIPS CARD
                            CustomCard(
                              backgroundColor: AppTheme.klooigeldPaars,
                              shadowColor: Colors.black26,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TipsScreen()),
                                );
                                _refreshData();
                              },
                              padding: const EdgeInsets.all(16),
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

                            /// KLOOI GAMES + KLOOI SHOP
                            Row(
                              children: [
                                Expanded(
                                  child: CustomCard(
                                    backgroundColor: AppTheme.klooigeldBlauw,
                                    shadowColor: Colors.black26,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LearningRoadScreen()),
                                      );
                                      _refreshData();
                                    },
                                    padding: const EdgeInsets.all(16),
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
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RewardsShopScreen()),
                                      );
                                      _refreshData();
                                    },
                                    padding: const EdgeInsets.all(16),
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

                            /// ACCOUNT
                            CustomCard(
                              backgroundColor: AppTheme.klooigeldPaars,
                              shadowColor: Colors.black26,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                                );
                                _refreshData();
                              },
                              padding: const EdgeInsets.all(16),
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

                            /// TRANSACTIONS SECTION
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
                            if (_transactions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
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
                              SizedBox(
                                height: _transactions.length > 3
                                    ? 3 * 70.0 + 2
                                    : _transactions.length * 70.0,
                                child: ListView.separated(
                                  physics: _transactions.length > 3
                                      ? const AlwaysScrollableScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                                  itemCount: _transactions.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 0),
                                  itemBuilder: (context, index) {
                                    final tx = _transactions[index];
                                    final sign = tx.amount > 0
                                        ? '+'
                                        : (tx.amount < 0 ? '-' : '');
                                    final formattedAmount = tx.amount != 0
                                        ? '$sign${tx.amount.abs()} K'
                                        : '0 K';

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

            /// NOTIFICATION DROPDOWN
            if (_showNotifications)
              NotificationDropdown(
                onClose: _closeNotifications,
                onKlooicashUpdated: _refreshData,
              ),

            /// DAILY TASK OVERLAY
            if (_showDailyTasksOverlay)
              DailyTaskOverlay(onClose: _toggleDailyTasksOverlay),

            /// INFO OVERLAY
            if (_showInfoOverlay)
              InfoOverlay(onClose: _toggleInfoOverlay),
          ],
        ),
      ),
    );
  }
}
