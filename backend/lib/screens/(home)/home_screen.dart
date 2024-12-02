import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../components/custom_card.dart';
import '../../components/transaction_tile.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<String>? _usernameFuture;
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
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User';
  }

  Future<String?> _getAvatarImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatarImagePath');
  }

  Future<bool> _hasNotifications() async {
    // placeholder logic
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasNotifications') ?? false;
  }


  @override
  Widget build(BuildContext context) {
    _subtitles.shuffle();
    String randomSubtitle = _subtitles.first;

    double percentage = 1.0; // needs to be changed, demonstration purpose only

    String dailyTasksSubtitle =
        percentage == 1.0 ? 'ALL TASKS COMPLETED!' : 'YOU HAVE MORE TO GO!';

    return Scaffold(
      backgroundColor: AppTheme.nearlyWhite,
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _usernameFuture,
          builder: (context, snapshot) {
            String username = snapshot.data?.toUpperCase() ?? 'USER';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 26.0, horizontal: 26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FutureBuilder<bool>(
                          future: _hasNotifications(), // Method to check notification status
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
                                // TODO: Handle email icon action
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        FutureBuilder<String?>(
                          future: _getAvatarImagePath(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                File(snapshot.data!).existsSync()) {
                              return CircleAvatar(
                                backgroundImage: FileImage(File(snapshot.data!)),
                              );
                            } else {
                              return Container();
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
                          offset: Offset(0, -8), // Adjust '-5' to move it further up or down
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
                        // Card 1: Balance
                        CustomCard(
                          backgroundColor: AppTheme.klooigeldGroen,
                          shadowColor: Colors.black26,
                          onTap: () {
                            // TODO: Handle balance card tap
                          },
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
                                    '1.024',
                                    style: TextStyle(
                                      fontFamily: AppTheme.neighbor,
                                      fontSize: 24,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Transform.translate(
                                    offset: Offset(0, 3),
                                    child: Text(
                                      'K',
                                      style: TextStyle(
                                        fontFamily: AppTheme.logoFont1,
                                        fontSize: 28,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        CustomCard(
                          backgroundColor: AppTheme.klooigeldRoze,
                          shadowColor: Colors.black26,
                          onTap: () {
                            // TODO: Handle daily tasks card tap
                          },
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Circle with progress and texts
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Circle with progress
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
                                          color: AppTheme.klooigeldRoze, // Same color as card
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Texts
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Transform.translate(
                                        offset: Offset(0, 2), // move the text up or down
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
                                        offset: Offset(0, -2), // move the text up or down
                                        child: Text(
                                          dailyTasksSubtitle,
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
                              // Icon for Daily Tasks
                              const FaIcon(
                                FontAwesomeIcons.list,
                                size: 28,
                                color: AppTheme.white,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        // Card 3: TIPS
                        CustomCard(
                          backgroundColor: AppTheme.klooigeldPaars,
                          shadowColor: Colors.black26,
                          onTap: () {
                            // TODO: Handle tips card tap
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
                        // Cards 4 and 5: KLOOI GAMES and KLOOI SHOP
                        Row(
                          children: [
                            Expanded(
                              child: CustomCard(
                                backgroundColor: AppTheme.klooigeldBlauw,
                                shadowColor: Colors.black26,
                                onTap: () {
                                  // TODO: Handle KLOOI GAMES card tap
                                },
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0, 2), // Move icon up by 8 pixels
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
                                  // TODO: Handle KLOOI SHOP card tap
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
                        // Card 6: ACCOUNT
                        CustomCard(
                          backgroundColor: AppTheme.klooigeldPaars,
                          shadowColor: Colors.black26,
                          onTap: () {
                            // TODO: Handle account card tap
                          },
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
                          separatorBuilder: (context, index) =>
                              const Divider(),
                          itemBuilder: (context, index) {
                            // Sample transactions
                            final transactions = [
                              TransactionTile(
                                description: 'SHOES',
                                amount: '-110 K',
                                date: 'March 27',
                              ),
                              TransactionTile(
                                description: 'COFFEE',
                                amount: '-5 K',
                                date: 'March 26',
                              ),
                              TransactionTile(
                                description: 'SALARY',
                                amount: '+2.000 K',
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
