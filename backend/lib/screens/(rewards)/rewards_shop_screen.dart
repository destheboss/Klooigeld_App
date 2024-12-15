import 'dart:async';
import 'dart:convert';  // For jsonEncode/Decode if we store transaction objects in SharedPreferences
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../components/widgets/rewards/category_icon.dart';
import '../../components/widgets/rewards/shop_item_card.dart';
import '../../components/widgets/rewards/purchase_overlay.dart';
import '../../services/item_service.dart';

/// Simple model for storing transactions in SharedPreferences
class TransactionRecord {
  final String description;
  final int amount; // negative for purchases, positive for income
  final String date; // stored as e.g. '2024-12-15'

  TransactionRecord({
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'date': date,
      };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      description: json['description'],
      amount: json['amount'],
      date: json['date'],
    );
  }
}

class RewardsShopScreen extends StatefulWidget {
  final bool isModal;
  final int? initialCategoryId;
  final VoidCallback? onClose;
  final ValueChanged<int>? onKlooicashUpdate;
  final int? initialBalance;

  /// Indicates whether this purchase session should be ephemeral (e.g., scenario replay).
  /// If `true`, items bought do NOT get permanently added to the transactions list.
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
  Set<int> _alreadyOwnedItems = {};      // items purchased in earlier sessions
  Set<int> _purchasedThisSession = {};   // items purchased *now*, returned to caller

  /// Key for a dedicated ScaffoldMessenger inside the modal so the snack bar
  /// won't appear behind the modal.
  final GlobalKey<ScaffoldMessengerState> _modalMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

    // If this is a scenario modal specifically for category #4 (quests), limit categories/items
    if (widget.isModal && widget.initialCategoryId == 4) {
      _categories = _categories.where((c) => c.id == 4).toList();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    }

    _filterItems('', _selectedCategory);
    _loadData();

    _searchFocusNode.addListener(() {
      setState(() {}); // rebuild UI if focus changes
    });
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Use scenario-provided ephemeral balance if present, else user’s normal balance
    if (widget.initialBalance != null) {
      _klooicash = widget.initialBalance!;
    } else {
      _klooicash = prefs.getInt('klooicash') ?? 500;
    }

    // Items purchased in the past (permanent)
    final storedItems = prefs.getStringList('purchasedItems') ?? [];
    _alreadyOwnedItems = storedItems.map((e) => int.parse(e)).toSet();

    setState(() {});
  }

  Future<bool> _onWillPop() async {
    // Return the IDs of items purchased in *this* session back to the caller
    Navigator.pop(context, _purchasedThisSession);
    return false; // prevent default pop since we already called Navigator.pop
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

        // If scenario modal with categoryId=4, only show category #4 items
        if (widget.isModal && widget.initialCategoryId == 4 && item.categoryId != 4) {
          return false;
        }

        final matchesCategory = (category == null) || (item.categoryId == category.id);
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
    // Only allow clearing category if not restricted by isModal
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

  /// Called when user confirms buying an item in the overlay
  Future<void> _onBuyPressed() async {
    if (_selectedItemForPurchase == null) return;
    final item = _selectedItemForPurchase!;

    _klooicash -= item.price;
    _purchasedThisSession.add(item.id);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!widget.isEphemeral) {
      // PERMANENT purchase
      // 1) Add to permanent purchasedItems
      List<String> storedItems = prefs.getStringList('purchasedItems') ?? [];
      if (!storedItems.contains(item.id.toString())) {
        storedItems.add(item.id.toString());
        await prefs.setStringList('purchasedItems', storedItems);
      }

      // 2) Deduct from main user balance
      if (widget.initialBalance == null) {
        await prefs.setInt('klooicash', _klooicash);
      }

      // 3) Record this transaction in user’s transaction log
      await _addTransaction(
        description: item.name.toUpperCase(),
        amount: -item.price,
      );
    }

    // If ephemeral, we do NOT record a permanent transaction.

    // Notify scenario or parent UI of new ephemeral balance
    widget.onKlooicashUpdate?.call(_klooicash);

    _hidePurchaseOverlay();
    setState(() {});
  }

  /// Append a new transaction to the persistent transaction list
  Future<void> _addTransaction({
    required String description,
    required int amount,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing transactions
    final rawList = prefs.getStringList('user_transactions') ?? [];
    final List<TransactionRecord> existing = rawList.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return TransactionRecord.fromJson(map);
    }).toList();

    // Create new transaction with current date in YYYY-MM-DD format
    final now = DateTime.now();
    final dateString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final newTx = TransactionRecord(
      description: description,
      amount: amount, // negative for purchase
      date: dateString,
    );
    existing.insert(0, newTx); // Insert at top

    // Persist to SharedPreferences
    final newRawList = existing.map((tx) => jsonEncode(tx.toJson())).toList();
    await prefs.setStringList('user_transactions', newRawList);
  }

  /// If item is already purchased, show an alert ONLY in the modal’s local context if isModal == true.
  void _showPurchaseOverlay(ShopItem item) {
    final alreadyOwned = _alreadyOwnedItems.contains(item.id) || _purchasedThisSession.contains(item.id);
    if (alreadyOwned) {
      // Show a snack bar alert. If in modal mode, show in local scaffold messenger.
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.klooigeldRoze,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.klooigeldBlauw, width: 2),
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
        // If not modal, use the normal ScaffoldMessenger.
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: const Duration(seconds: 2),
            content: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.klooigeldRoze,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.klooigeldBlauw, width: 2),
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

  Widget _buildContent() {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
              child: Column(
                children: [
                  // Header row: close button + title + balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
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
                          child: const Icon(Icons.chevron_left_rounded, size: 30, color: AppTheme.nearlyBlack),
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

                      // If modal, show ephemeral balance
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
                            Image.asset('assets/images/currency.png', width: 12, height: 20),
                          ],
                        )
                      else
                        // Otherwise, show a popup or more menu
                        PopupMenuButton<int>(
                          onSelected: (value) {},
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

                  // Category scrolling (hidden if modal locked to category #4)
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
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                                      border: Border.all(color: Colors.black, width: 1.5),
                                    ),
                                    child: const Icon(Icons.close, size: 16, color: Colors.black),
                                  ),
                                )
                              : const Icon(Icons.search, color: AppTheme.black),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Items grid
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
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isPurchased = _alreadyOwnedItems.contains(item.id) ||
                                  _purchasedThisSession.contains(item.id);
                              return ShopItemCard(
                                name: item.name,
                                imagePath: item.imagePath,
                                price: item.price,
                                colors: item.colors,
                                isPurchased: isPurchased,
                                onTap: () => _showPurchaseOverlay(item),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // Purchase overlay
          if (_showOverlay && _selectedItemForPurchase != null)
            PurchaseOverlay(
              itemName: _selectedItemForPurchase!.name,
              imagePath: _selectedItemForPurchase!.imagePath,
              itemPrice: _selectedItemForPurchase!.price,
              colors: _selectedItemForPurchase!.colors,
              onBuy: _onBuyPressed,
              onCancel: _hidePurchaseOverlay,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we're shown as a modal, wrap content in its own Scaffold + ScaffoldMessenger
    // so that SnackBars appear ABOVE the modal rather than behind it.
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
      // Full screen shop
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
