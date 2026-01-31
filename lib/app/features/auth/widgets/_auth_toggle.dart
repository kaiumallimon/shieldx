import 'package:flutter/material.dart';
import 'package:shieldx/app/core/themes/_app_colors.dart';

class AuthToggle extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onToggle;

  const AuthToggle({
    super.key,
    required this.selectedIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            context: context,
            theme: theme,
            label: 'Register',
            index: 0,
            isSelected: selectedIndex == 0,
          ),
          _buildToggleButton(
            context: context,
            theme: theme,
            label: 'Login',
            index: 1,
            isSelected: selectedIndex == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: AnimatedContainer(
        key: ValueKey('${label.toLowerCase()}_container'),
        duration: const Duration(milliseconds: 300),
        margin: isSelected ? const EdgeInsets.all(6) : EdgeInsets.zero,
        child: Material(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => onToggle(index),
            borderRadius: BorderRadius.circular(8),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
