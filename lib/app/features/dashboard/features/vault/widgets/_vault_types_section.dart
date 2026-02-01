import 'package:flutter/material.dart';

class VaultTypesSection extends StatelessWidget {
  /// List of type names to display (e.g., Login, API Key, etc.)
  final List<String> types;

  /// Callback when the add type button is tapped
  final VoidCallback? onAddType;

  /// Callback when a type chip is tapped, receives the type name
  final Function(String)? onTypeTap;

  const VaultTypesSection({
    super.key,
    required this.types,
    this.onAddType,
    this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Add type button (circular with icon) - LEFT SIDE
          GestureDetector(
            onTap: onAddType,
            child: Container(
              height: 45,
              width: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.add, color: theme.colorScheme.onSecondary),
            ),
          ),
          // Scrollable types with fade effect
          Expanded(
            child: ShaderMask(
              // Creates a gradient fade on both edges (left 15%, right 5%)
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
                  stops: const [0.0, 0.15, 0.95, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Scroll from right to left
                  children: List.generate(types.length, (index) {
                    return GestureDetector(
                      onTap: () => onTypeTap?.call(types[index]),
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withAlpha(50),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          types[index],
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          // Fixed "Type" label - RIGHT SIDE
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withAlpha(50),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'Type',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
