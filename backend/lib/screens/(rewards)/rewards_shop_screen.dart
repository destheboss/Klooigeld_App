import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../components/widgets/rewards/category_icon.dart';
import '../../components/widgets/rewards/shop_item_card.dart';
import '../../components/widgets/rewards/purchase_overlay.dart';
import '../../services/item_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardsShopScreen extends StatefulWidget {
  final bool isModal;
  final int? initialCategoryId;
  final VoidCallback? onClose;
  final ValueChanged<int>? onKlooicashUpdate;
  final int? initialBalance;

  const RewardsShopScreen({
    super.key,
    this.isModal = false,
    this.initialCategoryId,
    this.onClose,
    this.onKlooicashUpdate,
    this.initialBalance,
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
  Set<int> _purchasedItems = {};

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

    if (widget.isModal) {
      // Only quest category if modal
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

    List<String> storedItems = prefs.getStringList('purchasedItems') ?? [];
    _purchasedItems = storedItems.map((e) => int.parse(e)).toSet();
    
    setState(() {});
  }


  Future<bool> _onWillPop() async {
    Navigator.pop(context, _purchasedItems);
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
        if (widget.isModal && item.categoryId != 4) {
          return false;
        }
        final matchesCategory = category == null || item.categoryId == category.id;
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

    Future<void> _onBuyPressed() async {
    if (_selectedItemForPurchase == null) return;
    ShopItem item = _selectedItemForPurchase!;

    // CHECKLIST: Deduct immediately, store in prefs
    if (!_purchasedItems.contains(item.id)) {
      _klooicash -= item.price;
      _purchasedItems.add(item.id);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> storedItems = prefs.getStringList('purchasedItems') ?? [];
      storedItems.add(item.id.toString());
      await prefs.setStringList('purchasedItems', storedItems);

      if (widget.initialBalance == null) {
        // If not launched from game, update main klooicash
        await prefs.setInt('klooicash', _klooicash);
      }

      widget.onKlooicashUpdate?.call(_klooicash);
    }

    _hidePurchaseOverlay();
    setState(() {});
  }


  void _showPurchaseOverlay(ShopItem item) {
    // CHECKLIST: If item already purchased, do not show overlay again.
    if (_purchasedItems.contains(item.id)) {
      // Already purchased
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.isModal)
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context, _purchasedItems);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              size: 30,
                              color: AppTheme.nearlyBlack,
                            ),
                          ),
                        )
                      else
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _unfocusSearch();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              size: 30,
                              color: AppTheme.nearlyBlack,
                            ),
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
                      if (!widget.isModal)
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
                                children: [
                                  const SizedBox(width: 4),
                                  Text(
                                    'Account',
                                    style: TextStyle(
                                      fontFamily: AppTheme.neighbor,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  const FaIcon(FontAwesomeIcons.user,
                                      size: 16, color: Colors.black),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                children: [
                                  const SizedBox(width: 4),
                                  Text(
                                    'Tips',
                                    style: TextStyle(
                                      fontFamily: AppTheme.neighbor,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 43),
                                  const FaIcon(FontAwesomeIcons.lightbulb,
                                      size: 16, color: Colors.black),
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
                              child: const Icon(
                                Icons.more_vert,
                                color: AppTheme.nearlyBlack,
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Text(
                              _klooicash.toString(),
                              style: TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: AppTheme.black,
                              ),
                            ),
                            const SizedBox(width:4),
                            Image.asset('assets/images/currency.png',
                                width:12,height:20),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height:0),

                  if (!widget.isModal)
                    SizedBox(
                      height:100,
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
                            const SizedBox(width:20),
                            for (var c in _categories)
                              Padding(
                                padding: const EdgeInsets.only(right:20.0),
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

                  const SizedBox(height:16),
                  Container(
                    height:40,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black, width:1.5),
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
                                contentPadding: EdgeInsets.symmetric(vertical:8,horizontal:16),
                              ),
                              style: TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontSize:14,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right:8),
                          child: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _clearSearch();
                                    _unfocusSearch();
                                  },
                                  child: Container(
                                    width:24,
                                    height:24,
                                    decoration: BoxDecoration(
                                      color: AppTheme.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width:1.5),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size:16,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  color: AppTheme.black,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height:28),

                  if (!widget.isModal)
                    const SizedBox(),

                  if (widget.isModal) const SizedBox(height:8),

                  Expanded(
                    child: _filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'No results',
                              style: TextStyle(
                                fontFamily: AppTheme.neighbor,
                                fontSize:16,
                                color: AppTheme.grey,
                              ),
                            ),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:2,
                              crossAxisSpacing:16,
                              mainAxisSpacing:16,
                              childAspectRatio:0.7,
                            ),
                            itemCount: _filteredItems.length,
                            itemBuilder: (context,index) {
                              final item = _filteredItems[index];
                              return ShopItemCard(
                                name: item.name,
                                imagePath: item.imagePath,
                                price: item.price,
                                colors: item.colors,
                                onTap: () => _showPurchaseOverlay(item),
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
    Widget content = _buildContent();

    if (widget.isModal) {
      return Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width*0.9,
            height: MediaQuery.of(context).size.height*0.8,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: content,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: _unfocusSearch,
        child: Scaffold(backgroundColor: AppTheme.nearlyWhite, body: content),
      );
    }
  }
}