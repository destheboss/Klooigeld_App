// lib/screens/rewards/rewards_shop_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:backend/screens/(account)/account_screen.dart';
import 'package:backend/screens/(tips)/tips_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../components/widgets/rewards/category_icon.dart';
import '../../components/widgets/rewards/shop_item_card.dart';
import '../../components/widgets/rewards/purchase_overlay.dart';
import '../../services/item_service.dart';
import '../../services/transaction_service.dart';

// NEW: Define PurchaseRecord to store itemId and selectedColorName
class PurchaseRecord {
  final int itemId;
  final String selectedColorName;

  PurchaseRecord({required this.itemId, required this.selectedColorName});

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'selectedColorName': selectedColorName,
      };

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) =>
      PurchaseRecord(
        itemId: json['itemId'],
        selectedColorName: json['selectedColorName'],
      );
}

class RewardsShopScreen extends StatefulWidget {
  final bool isModal;
  final int? initialCategoryId;
  final VoidCallback? onClose;
  final ValueChanged<int>? onKlooicashUpdate;
  final int? initialBalance;
  final bool isEphemeral;

  const RewardsShopScreen({
    super.key,
    this.isModal = false,
    this.initialCategoryId,
    this.onClose,
    this.onKlooicashUpdate,
    this.initialBalance,
    this.isEphemeral = false,
  });

  @override
  State<RewardsShopScreen> createState() => _RewardsShopScreenState();
}

class _RewardsShopScreenState extends State<RewardsShopScreen> {
  final ItemService _itemService = ItemService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late List<Category> _categories;
  late List<ShopItem> _allItems;
  late List<ShopItem> _filteredItems;

  Category? _selectedCategory;
  Timer? _debounce;

  bool _showOverlay = false;
  ShopItem? _selectedItemForPurchase;

  int _klooicash = 500;
  List<PurchaseRecord> _alreadyOwnedItems = []; // Changed to List<PurchaseRecord>
  Set<int> _purchasedThisSession = {};

  final GlobalKey<ScaffoldMessengerState> _modalMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // NEW: Track if promotional offer is active
  bool _promotionalOfferActive = false;

  @override
  void initState() {
    super.initState();
    _categories = _itemService.fetchCategories();
    _allItems = _itemService.fetchItems();

    if (widget.initialCategoryId != null) {
      _selectedCategory = _categories.firstWhere(
        (c) => c.id == widget.initialCategoryId,
        orElse: () => _categories[0],
      );
    }

    if (widget.isModal && widget.initialCategoryId == 4) {
      _categories = _categories.where((c) => c.id == 4).toList();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    }

    _filterItems('', _selectedCategory);
    _loadData();

    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (widget.initialBalance != null) {
      _klooicash = widget.initialBalance!;
    } else {
      _klooicash = prefs.getInt('klooicash') ?? 500;
    }

    final storedItems = prefs.getStringList('purchasedItems') ?? [];
    _alreadyOwnedItems = storedItems.map((e) {
  try {
    final decoded = jsonDecode(e);
    if (decoded is Map<String, dynamic>) {
      return PurchaseRecord.fromJson(decoded);
    } else {
      // Handle unexpected data type
      print('Unexpected data format: $decoded');
      return null;
    }
  } catch (error) {
    // Handle JSON parsing errors
    print('Error decoding purchased item: $error');
    return null;
  }
}).whereType<PurchaseRecord>().toList();


    // NEW: Check if promotional offer was shown (in NotificationService) and is active
    // If the promoOfferKey was set to true, promotional offers apply.
    bool promoOfferShown = prefs.getBool('promo_offer_shown') ?? false;
    _promotionalOfferActive = promoOfferShown;

    setState(() {});
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, _purchasedThisSession);
    return false;
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterItems(query, _selectedCategory);
    });
    setState(() {});
  }

  void _filterItems(String query, Category? category) {
    query = query.trim().toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesName = item.name.toLowerCase().contains(query);

        if (widget.isModal &&
            widget.initialCategoryId == 4 &&
            item.categoryId != 4) {
          return false;
        }

        final matchesCategory = (category == null) ||
            (item.categoryId == category.id);
        return matchesName && matchesCategory;
      }).toList();
    });
  }

  void _onCategorySelected(Category category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterItems(_searchController.text, category);
  }

  void _clearCategorySelection() {
    if (!widget.isModal) {
      setState(() {
        _selectedCategory = null;
      });
      _filterItems(_searchController.text, null);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filterItems('', _selectedCategory);
    setState(() {});
  }

  void _unfocusSearch() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _onBuyPressed(String selectedColorName) async {
    if (_selectedItemForPurchase == null) return;
    final item = _selectedItemForPurchase!;

    final effectivePrice = _getEffectivePrice(item); // Get discounted price if applicable

    setState(() {
      _klooicash -= effectivePrice;
      _purchasedThisSession.add(item.id);
      _alreadyOwnedItems
          .add(PurchaseRecord(itemId: item.id, selectedColorName: selectedColorName));
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!widget.isEphemeral) {
      List<String> storedItems = prefs.getStringList('purchasedItems') ?? [];
      // Store as JSON string with itemId and selectedColorName
      final purchaseRecord = PurchaseRecord(
          itemId: item.id, selectedColorName: selectedColorName);
      storedItems.add(jsonEncode(purchaseRecord.toJson()));
      await prefs.setStringList('purchasedItems', storedItems);

      if (widget.initialBalance == null) {
        await prefs.setInt('klooicash', _klooicash);
      }

      await _addTransaction(
        description: item.name.toUpperCase(),
        amount: -effectivePrice,
      );
    }

    widget.onKlooicashUpdate?.call(_klooicash);

    _hidePurchaseOverlay();
    setState(() {});
  }

  Future<void> _addTransaction({
    required String description,
    required int amount,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('user_transactions') ?? [];
    final List<TransactionRecord> existing = rawList.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return TransactionRecord.fromJson(map);
    }).toList();

    final now = DateTime.now();
    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final newTx = TransactionRecord(
      description: description,
      amount: amount,
      date: dateString,
    );
    existing.insert(0, newTx);

    final newRawList =
        existing.map((tx) => jsonEncode(tx.toJson())).toList();
    await prefs.setStringList('user_transactions', newRawList);
  }

  void _showPurchaseOverlay(ShopItem item) {
    final alreadyOwned = _alreadyOwnedItems
            .any((purchase) => purchase.itemId == item.id) ||
        _purchasedThisSession.contains(item.id);
    if (alreadyOwned) {
      if (widget.isModal) {
        _modalMessengerKey.currentState?.removeCurrentSnackBar();
        _modalMessengerKey.currentState?.showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: const Duration(seconds: 2),
            content: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.klooigeldRoze,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.klooigeldBlauw, width: 2),
                ),
                child: const Text(
                  "Item already purchased",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.klooigeldBlauw,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: const Duration(seconds: 2),
            content: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.klooigeldRoze,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.klooigeldBlauw, width: 2),
                ),
                child: const Text(
                  "Item already purchased",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.klooigeldBlauw,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedItemForPurchase = item;
      _showOverlay = true;
    });
  }

  void _hidePurchaseOverlay() {
    setState(() {
      _selectedItemForPurchase = null;
      _showOverlay = false;
    });
  }

  // Calculate the effective price after discount if promotionalOfferActive
  // Apply a 20% discount to categoryId == 1 (shoes).
  int _getEffectivePrice(ShopItem item) {
    if (_promotionalOfferActive && item.categoryId == 1) {
      return (item.price * 0.8).round(); // 20% discount
    }
    return item.price;
  }

  Widget _buildContent() {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _unfocusSearch();
                          Navigator.pop(context, _purchasedThisSession);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(Icons.chevron_left_rounded,
                              size: 30, color: AppTheme.nearlyBlack),
                        ),
                      ),
                      Text(
                        'SHOP',
                        style: TextStyle(
                          fontFamily: AppTheme.titleFont,
                          fontSize: 56,
                          color: AppTheme.nearlyBlack2,
                        ),
                      ),
                      if (widget.isModal)
                        Row(
                          children: [
                            Text(
                              _klooicash.toString(),
                              style: const TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: AppTheme.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Image.asset('assets/images/currency.png',
                                width: 12, height: 20),
                          ],
                        )
                      else
                        PopupMenuButton<int>(
                        onSelected: (value) {
                          if (value == 1) {
                            // Navigate to Account Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AccountScreen()),
                            );
                          } else if (value == 2) {
                            // Navigate to Tips Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TipsScreen()),
                            );
                          }
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
                              children: const [
                                SizedBox(width: 4),
                                Text(
                                  'Account',
                                  style: TextStyle(
                                    fontFamily: AppTheme.neighbor,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 15),
                                FaIcon(FontAwesomeIcons.user, size: 16, color: Colors.black),
                              ],
                            ),
                          ),
                          PopupMenuItem<int>(
                            value: 2,
                            child: Row(
                              children: const [
                                SizedBox(width: 4),
                                Text(
                                  'Tips',
                                  style: TextStyle(
                                    fontFamily: AppTheme.neighbor,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 43),
                                FaIcon(FontAwesomeIcons.lightbulb, size: 16, color: Colors.black),
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
                            ),
                            child: const Icon(Icons.more_vert, color: AppTheme.nearlyBlack),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),

                  if (!widget.isModal)
                    SizedBox(
                      height: 100,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CategoryIcon(
                              icon: Icons.all_inclusive,
                              label: 'All',
                              isSelected: _selectedCategory == null,
                              onTap: _clearCategorySelection,
                              backgroundColor: AppTheme.klooigeldBlauw,
                            ),
                            const SizedBox(width: 20),
                            for (var c in _categories)
                              Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: CategoryIcon(
                                  icon: c.icon,
                                  label: c.name,
                                  isSelected: _selectedCategory?.id == c.id,
                                  onTap: () => _onCategorySelected(c),
                                  backgroundColor: c.color,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -7),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchChanged,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                              ),
                              style: const TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontSize: 14,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _clearSearch();
                                    _unfocusSearch();
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: Colors.black, width: 1.5),
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 16, color: Colors.black),
                                  ),
                                )
                              : const Icon(Icons.search,
                                  color: AppTheme.black),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Expanded(
                    child: _filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'No results',
                              style: TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontSize: 16,
                                color: AppTheme.grey,
                              ),
                            ),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isPurchased = _alreadyOwnedItems
                                      .any((purchase) =>
                                          purchase.itemId == item.id) ||
                                  _purchasedThisSession.contains(item.id);

                              // Determine prices for display
                              final originalPrice = item.price;
                              final discountedPrice =
                                  _promotionalOfferActive && item.categoryId == 1
                                      ? (item.price * 0.8).round()
                                      : null;

                              // Determine the purchased color name if already purchased
                              String? purchasedColorName;
                              if (isPurchased) {
                                final purchaseRecord = _alreadyOwnedItems.firstWhere(
                                    (purchase) => purchase.itemId == item.id,
                                    orElse: () => PurchaseRecord(
                                        itemId: item.id,
                                        selectedColorName: item.colorNames[0]));
                                purchasedColorName = purchaseRecord.selectedColorName;
                              }

                              return ShopItemCard(
                                name: item.name,
                                imagePath: item.imagePath, // Pass base imagePath
                                price: originalPrice,
                                colors: item.colors,
                                colorNames: item.colorNames, // Pass colorNames
                                onTap: () => _showPurchaseOverlay(item),
                                isPurchased: isPurchased,
                                discountedPrice: discountedPrice,
                                purchasedColorName:
                                    isPurchased ? purchasedColorName : null, // Pass purchasedColorName
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          if (_showOverlay && _selectedItemForPurchase != null)
            PurchaseOverlay(
              itemName: _selectedItemForPurchase!.name,
              imagePath: _selectedItemForPurchase!.imagePath, // Pass base imagePath
              itemPrice: _selectedItemForPurchase!.price,
              colors: _selectedItemForPurchase!.colors,
              colorNames: _selectedItemForPurchase!.colorNames, // Pass colorNames
              onBuy: _onBuyPressed,
              onCancel: _hidePurchaseOverlay,
              promotionalOfferActive:
                  _promotionalOfferActive && _selectedItemForPurchase!.categoryId == 1,
            ),
        ],
      ),
    );
  }

  // Helper method to get image path based on selected color
  String _getColorBasedImagePath(ShopItem item, int colorIndex) {
    String basePath = item.imagePath;
    // Remove the .png extension
    String withoutExtension = basePath.substring(0, basePath.lastIndexOf('.'));
    String extension = basePath.substring(basePath.lastIndexOf('.'));
    String colorName = item.colorNames[colorIndex];
    return '${withoutExtension}_$colorName$extension';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isModal) {
      return ScaffoldMessenger(
        key: _modalMessengerKey,
        child: Scaffold(
          backgroundColor: Colors.black54,
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildContent(),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _unfocusSearch,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: _buildContent(),
        ),
      );
    }
  }
}
