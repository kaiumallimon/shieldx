import 'package:flutter/material.dart';

class CircularActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final ScrollController scrollController;

  const CircularActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.margin,
    this.padding,
    this.iconSize,
    required this.scrollController,
  });

  @override
  State<CircularActionButton> createState() => _CircularActionButtonState();
}

class _CircularActionButtonState extends State<CircularActionButton> {
  bool _showShadow = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = widget.scrollController.offset > 0;
    if (shouldShow != _showShadow) {
      setState(() {
        _showShadow = shouldShow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: widget.margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: _showShadow
            ? [
                BoxShadow(
                  color: theme.colorScheme.onSurface.withAlpha(20),
                  offset: const Offset(2, 2),
                  blurRadius: 10,
                ),
              ]
            : [],
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(13),
          child: Icon(
            widget.icon,
            color: widget.iconColor ?? theme.colorScheme.onSurface,
            size: widget.iconSize ?? 20,
          ),
        ),
      ),
    );
  }
}
