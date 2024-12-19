// models/tip_category.dart
import 'package:flutter/material.dart';
import 'tip.dart';

class TipCategory {
  final String title;
  final IconData icon;
  final double progress;
  final Color backgroundColor;
  final List<Tip> tips;
  final int index;

  TipCategory({
    required this.index,
    required this.title,
    required this.icon,
    required this.progress,
    required this.backgroundColor,
    required this.tips,
  });

  TipCategory copyWith({double? progress}) {
    return TipCategory(
      index: index,
      title: title,
      icon: icon,
      progress: progress ?? this.progress,
      backgroundColor: backgroundColor,
      tips: tips,
    );
  }
}
