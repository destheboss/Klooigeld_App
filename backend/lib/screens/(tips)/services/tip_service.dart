// services/tip_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/tip_category.dart';

class TipService {
  static const String progressKeyPrefix = 'tip_category_progress_';

  // Load progress for all categories
  static Future<List<TipCategory>> loadProgress(List<TipCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    return categories.map((c) {
      double p = prefs.getDouble('$progressKeyPrefix${c.index}') ?? c.progress;
      return c.copyWith(progress: p);
    }).toList();
  }

  // Save progress (once read, set to 100%)
  static Future<void> markCategoryRead(TipCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$progressKeyPrefix${category.index}', 1.0);
  }
}
