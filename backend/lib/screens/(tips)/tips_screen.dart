// screens/(tips)/tips_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_theme.dart';
import 'models/tip_category.dart';
import 'widgets/tip_card.dart';
import 'widgets/tip_overlay.dart';
import 'data/tip_categories_data.dart';
import 'services/tip_service.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  List<TipCategory> _categories = [];
  int? _selectedIndex;
  bool get _showOverlay => _selectedIndex != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loaded = await TipService.loadProgress(initialTipCategories);
    setState(() {
      _categories = loaded;
    });
  }

  Future<void> _refreshCategories() async {
    final updated = await TipService.loadProgress(_categories);
    setState(() {
      _categories = updated;
    });
  }

  /// Mark tips as read in SharedPreferences if user visits the tips screen
  /// This can be made more fine-grained if you only want to mark them read after a certain condition.
  Future<void> _markTipsAsRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tips_read', true);
  }

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 160;
    const double overlapOffset = 115;
    final totalHeight = cardHeight + (_categories.length - 1) * overlapOffset;

    return Scaffold(
      backgroundColor: AppTheme.nearlyWhite,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    children: [
                      const SizedBox(height: 26),
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              // Mark tips as read when user leaves the screen
                              await _markTipsAsRead();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(52, 0, 0, 0),
                                    offset: Offset(3, 0),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 30,
                                color: AppTheme.nearlyBlack,
                              ),
                            ),
                          ),
                          Text(
                            'TIPS',
                            style: TextStyle(
                              fontFamily: AppTheme.titleFont,
                              fontSize: 56,
                              color: AppTheme.nearlyBlack2,
                            ),
                          ),
                          PopupMenuButton<int>(
                            onSelected: (value) {
                              // Placeholder for future menu actions
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black, width: 2),
                            ),
                            color: AppTheme.white,
                            elevation: 4,
                            itemBuilder: (context) => [
                              PopupMenuItem<int>(
                                value: 1,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 4),
                                    Text(
                                      'Settings',
                                      style: TextStyle(
                                        fontFamily: AppTheme.neighbor,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    const FaIcon(FontAwesomeIcons.gear, size: 16, color: Colors.black),
                                  ],
                                ),
                              ),
                              PopupMenuItem<int>(
                                value: 2,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 4),
                                    Text(
                                      'Filters',
                                      style: TextStyle(
                                        fontFamily: AppTheme.neighbor,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    const FaIcon(FontAwesomeIcons.filter, size: 16, color: Colors.black),
                                  ],
                                ),
                              ),
                            ],
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(52, 0, 0, 0),
                                      offset: Offset(-3, 0),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.more_vert,
                                  color: AppTheme.nearlyBlack,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stacked Cards Layout
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      height: totalHeight + 80,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            for (int i = 0; i < _categories.length; i++)
                              Positioned(
                                top: i * overlapOffset,
                                left: 26,
                                right: 26,
                                child: TipCard(
                                  category: _categories[i],
                                  onTap: () async {
                                    setState(() {
                                      _selectedIndex = i;
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_showOverlay && _selectedIndex != null)
            TipOverlay(
              category: _categories[_selectedIndex!],
              onClose: () async {
                await _refreshCategories();
                setState(() {
                  _selectedIndex = null;
                });
              },
            ),
        ],
      ),
    );
  }
}
