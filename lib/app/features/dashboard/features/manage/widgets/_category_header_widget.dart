import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CategoryHeaderWidget extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final int itemCount;

  const CategoryHeaderWidget({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor,
            categoryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            categoryIcon,
            size: 48,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 12),
          Text(
            categoryName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$itemCount passwords',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
