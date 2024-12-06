import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color backgroundColor;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category circle icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Category label: use neighbor for body text
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.neighbor,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          // Underline if selected
          Container(
            width: 20,
            height: isSelected ? 3 : 0,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
