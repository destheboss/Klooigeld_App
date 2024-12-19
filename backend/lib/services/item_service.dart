// lib/services/item_service.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class Category {
  final int id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class ShopItem {
  final int id;
  final String name;
  final String imagePath; // Base image path without color suffix
  final int price;
  final int categoryId;
  final List<Color> colors;
  final List<String> colorNames; // Maps each color to its name

  ShopItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.categoryId,
    required this.colors,
    required this.colorNames,
  });
}

class ItemService {
  List<Category> fetchCategories() {
    return [
      Category(
          id: 1,
          name: 'Shoes',
          icon: FontAwesomeIcons.shoePrints,
          color: AppTheme.klooigeldGroen),
      Category(
          id: 2,
          name: 'Hats',
          icon: FontAwesomeIcons.hatCowboy,
          color: AppTheme.klooigeldRoze),
      Category(
          id: 3,
          name: 'Clothes',
          icon: FontAwesomeIcons.tshirt,
          color: AppTheme.klooigeldPaars),
      Category(
          id: 4,
          name: 'Quests',
          icon: FontAwesomeIcons.gamepad,
          color: AppTheme.klooigeldBlauw),
    ];
  }

  List<ShopItem> fetchItems() {
    return [
      ShopItem(
        id: 101,
        name: 'Air Jordan 1 High',
        imagePath: 'assets/images/shop/shoes1.png',
        price: 120,
        categoryId: 1,
        colors: [
          const Color.fromARGB(255, 255, 102, 0),
          Colors.blue,
          Colors.green
        ],
        colorNames: ['orange', 'blue', 'green'], // Corresponding color names
      ),
      ShopItem(
        id: 102,
        name: 'Summer Hat',
        imagePath: 'assets/images/shop/hat1.png',
        price: 60,
        categoryId: 2,
        colors: [Colors.brown, Colors.black],
        colorNames: ['brown', 'black'],
      ),
      ShopItem(
        id: 103,
        name: 'Stylish Jacket',
        imagePath: 'assets/images/shop/clothes1.png',
        price: 200,
        categoryId: 3,
        colors: [Colors.black],
        colorNames: ['black'],
      ),
      ShopItem(
        id: 104,
        name: 'Casual Crocs',
        imagePath: 'assets/images/shop/shoes2.png',
        price: 90,
        categoryId: 1,
        colors: [Colors.white, Colors.black],
        colorNames: ['white', 'black'],
      ),
      ShopItem(
        id: 201,
        name: 'Bouquet of Roses',
        imagePath: 'assets/images/shop/flower1.png',
        price: 10,
        categoryId: 4,
        colors: [Colors.red, Colors.blue],
        colorNames: ['red', 'blue'],
      ),
      ShopItem(
        id: 202,
        name: 'Chocolate',
        imagePath: 'assets/images/shop/chocolate1.png',
        price: 5,
        categoryId: 4,
        colors: [Colors.transparent],
        colorNames: ['transparent'],
      ),
    ];
  }
}
