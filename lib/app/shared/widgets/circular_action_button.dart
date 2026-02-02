import 'package:flutter/material.dart';

class CircularActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  const CircularActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.margin,
    this.padding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withAlpha(20),
            offset: const Offset(2, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.onSurface,
          size: iconSize ?? 20,
        ),
      ),
    );
  }
}
