import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../components/widgets/rewards/category_icon.dart';
import '../../components/widgets/rewards/shop_item_card.dart';
import '../../components/widgets/rewards/purchase_overlay.dart';
import '../../services/item_service.dart';

class RewardsShopScreen extends StatefulWidget {
  const RewardsShopScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _categories = _itemService.fetchCategories();
    _allItems = _itemService.fetchItems();
    _filterItems('', null);

    // Listen to focus changes on the search bar.
    // If the keyboard is hidden by system actions, the searchFocusNode will lose focus.
    _searchFocusNode.addListener(() {
      // If focus is lost (keyboard hidden), we just update the UI if needed.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterItems(query, _selectedCategory);
    });
    setState(() {}); // Update UI for icon changes
  }

  void _filterItems(String query, Category? category) {
    query = query.trim().toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        final matchesName = item.name.toLowerCase().contains(query);
        // Exclude quest category items from "All"
        if (category == null && item.categoryId == 4) {
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
    setState(() {
      _selectedCategory = null;
    });
    _filterItems(_searchController.text, null);
  }

  void _viewItemDetails(ShopItem item) {
    // Placeholder
  }

  void _showPurchaseOverlay(ShopItem item) {
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

  void _onBuyPressed() {
    // Placeholder buy logic
    _hidePurchaseOverlay();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus the search bar if user taps anywhere outside it.
        _unfocusSearch();
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppTheme.nearlyWhite,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                          'SHOP',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFont,
                            fontSize: 56,
                            color: AppTheme.nearlyBlack2,
                          ),
                        ),
                        PopupMenuButton<int>(
                          onSelected: (value) {
                            // Placeholder for menu actions
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
                                    'Account',
                                    style: TextStyle(
                                      fontFamily: AppTheme.neighbor,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  const FaIcon(FontAwesomeIcons.user, size: 16, color: Colors.black),
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
                                  const FaIcon(FontAwesomeIcons.lightbulb, size: 16, color: Colors.black),
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

                    const SizedBox(height: 0),

                    // Category Row
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

                            CategoryIcon(
                              icon: _categories[0].icon,
                              label: _categories[0].name,
                              isSelected: _selectedCategory?.id == 1,
                              onTap: () => _onCategorySelected(_categories[0]),
                              backgroundColor: _categories[0].color,
                            ),
                            const SizedBox(width: 20),

                            CategoryIcon(
                              icon: _categories[1].icon,
                              label: _categories[1].name,
                              isSelected: _selectedCategory?.id == 2,
                              onTap: () => _onCategorySelected(_categories[1]),
                              backgroundColor: _categories[1].color,
                            ),
                            const SizedBox(width: 20),

                            CategoryIcon(
                              icon: _categories[2].icon,
                              label: _categories[2].name,
                              isSelected: _selectedCategory?.id == 3,
                              onTap: () => _onCategorySelected(_categories[2]),
                              backgroundColor: _categories[2].color,
                            ),
                            const SizedBox(width: 20),

                            CategoryIcon(
                              icon: _categories[3].icon,
                              label: _categories[3].name,
                              isSelected: _selectedCategory?.id == 4,
                              onTap: () => _onCategorySelected(_categories[3]),
                              backgroundColor: _categories[3].color,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Search Bar
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
                              offset: const Offset(0, -7), // Adjust text position
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: _onSearchChanged,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                style: TextStyle(
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
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
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

                    const SizedBox(height: 28),

                    // Items Grid
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

            // Purchase Overlay
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
      ),
    );
  }
}
