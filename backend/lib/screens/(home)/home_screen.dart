// screens/(home)/home_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../components/widgets/home/custom_card.dart';
import '../../components/widgets/home/transaction_tile.dart';
import '../../theme/app_theme.dart';
import '../../screens/(learning_road)/learning-road_screen.dart';
import '../../screens/(rewards)/rewards_shop_screen.dart';
import '../../screens/(tips)/tips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<String>? _usernameFuture;
  Future<int>? _klooicashFuture;

  final List<String> _subtitles = [
    'FEELING GOOD TODAY?',
    'READY TO EARN MORE?',
    'KEEP UP THE GREAT WORK!',
    'LET’S ACHIEVE SOMETHING NEW!',
    'MAKE TODAY COUNT!',
  ];

  @override
  void initState() {
    super.initState();
    _usernameFuture = _getUsername();
    _klooicashFuture = _getKlooicash();
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

  Future<bool> _hasNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasNotifications') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    _subtitles.shuffle();
    String randomSubtitle = _subtitles.first;

    double percentage = 1.0; // For demonstration only

    return Scaffold(
      backgroundColor: AppTheme.nearlyWhite,
      body: SafeArea(
        child: FutureBuilder(
          future: Future.wait([_usernameFuture!, _klooicashFuture!]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
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
                        FutureBuilder<bool>(
                          future: _hasNotifications(),
                          builder: (context, snapshot) {
                            String iconPath = 'assets/images/icons/email-notif.png'; // icon for demonstration
                            // String iconPath = 'assets/images/icons/email.png'; // Default icon
                            // if (snapshot.hasData && snapshot.data == true) {
                            //   iconPath = 'assets/images/icons/email-notif.png'; // Notification icon
                            // }
                            return IconButton(
                              icon: Image.asset(
                                iconPath,
                                width: 40,
                                height: 40,
                              ),
                              onPressed: () {
                                // Handle notifications
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        FutureBuilder<String?>(
                          future: _getAvatarImagePath(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null && File(snapshot.data!).existsSync()) {
                              return CircleAvatar(
                                radius: 20,
                                backgroundImage: FileImage(File(snapshot.data!)),
                              );
                            } else {
                              return CircleAvatar(
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
                          offset: Offset(0, -8),
                          child: Text(
                            randomSubtitle,
                            style: TextStyle(
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
                    // Main Cards Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance Card (now showing actual Klooicash)
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
                                    style: TextStyle(
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
                        // Daily Tasks Card (placeholder)
                        CustomCard(
                          backgroundColor: AppTheme.klooigeldRoze,
                          shadowColor: Colors.black26,
                          onTap: () {},
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                        offset: Offset(0, 2),
                                        child: Text(
                                          'DAILY TASKS',
                                          style: TextStyle(
                                            fontFamily: AppTheme.titleFont,
                                            fontSize: 24,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(0, -2),
                                        child: Text(
                                          percentage == 1.0 ? 'ALL TASKS COMPLETED!' : 'YOU HAVE MORE TO GO!',
                                          style: TextStyle(
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
                              const FaIcon(
                                FontAwesomeIcons.list,
                                size: 28,
                                color: AppTheme.white,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        // Tips Card
                        CustomCard(
                          backgroundColor: AppTheme.klooigeldPaars,
                          shadowColor: Colors.black26,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TipsScreen()),
                            );
                          },
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'TIPS',
                                style: TextStyle(
                                  fontFamily: AppTheme.titleFont,
                                  fontSize: 24,
                                  color: AppTheme.white,
                                ),
                              ),
                              const FaIcon(
                                FontAwesomeIcons.solidLightbulb,
                                size: 28,
                                color: AppTheme.white,
                              ),
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LearningRoadScreen()),
                                  );
                                },
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0, 2),
                                      child: const FaIcon(
                                        FontAwesomeIcons.gamepad,
                                        size: 48,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RewardsShopScreen()),
                                  );
                                },
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.bagShopping,
                                      size: 48,
                                      color: AppTheme.white,
                                    ),
                                    const SizedBox(height: 5),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ACCOUNT',
                                style: TextStyle(
                                  fontFamily: AppTheme.titleFont,
                                  fontSize: 24,
                                  color: AppTheme.white,
                                ),
                              ),
                              const FaIcon(
                                FontAwesomeIcons.solidCircleUser,
                                size: 28,
                                color: AppTheme.white,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Transactions Section
                        Text(
                          'TRANSACTIONS',
                          style: TextStyle(
                            fontFamily: AppTheme.neighbor,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 3,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final transactions = [
                              TransactionTile(
                                description: 'SHOES',
                                amount: '-110',
                                date: 'March 27',
                              ),
                              TransactionTile(
                                description: 'COFFEE',
                                amount: '-5',
                                date: 'March 26',
                              ),
                              TransactionTile(
                                description: 'SALARY',
                                amount: '+2.000',
                                date: 'March 25',
                              ),
                            ];
                            return transactions[index];
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
