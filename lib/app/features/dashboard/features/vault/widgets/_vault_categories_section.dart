import 'package:flutter/material.dart';

class VaultCategoriesSection extends StatelessWidget {
  /// List of category names to display
  final List<String> categories;

  /// Callback when the add category button is tapped
  final VoidCallback? onAddCategory;

  /// Callback when a category chip is tapped, receives the category name
  final Function(String)? onCategoryTap;

  const VaultCategoriesSection({
    super.key,
    required this.categories,
    this.onAddCategory,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Row(
        children: [
          // Fixed "Categories" label
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'Categories',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Scrollable categories with fade effect
          Expanded(
            child: ShaderMask(
              // Creates a gradient fade on both edges (left 5%, right 15%)
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.05, 0.85, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                    categories.length,
                    (index) {
                      return GestureDetector(
                        onTap: () => onCategoryTap?.call(categories[index]),
                        child: Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(50),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            categories[index],
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withAlpha(128),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Add category button (circular with icon)
          GestureDetector(
            onTap: onAddCategory,
            child: Container(
              height: 45,
              width: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
