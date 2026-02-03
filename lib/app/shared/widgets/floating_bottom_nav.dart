import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FloatingBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final ScrollController? scrollController;
  final bool showGradientOnScroll;

  const FloatingBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.scrollController,
    this.showGradientOnScroll = true,
  });

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with TickerProviderStateMixin {
  bool _showGradient = false;
  late AnimationController _rippleController;
  int? _rippleIndex;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Listen to scroll controller if provided
    if (widget.scrollController != null && widget.showGradientOnScroll) {
      widget.scrollController!.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null && widget.showGradientOnScroll) {
      widget.scrollController!.removeListener(_onScroll);
    }
    _rippleController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController == null) return;

    final shouldShow = widget.scrollController!.offset > 0;
    if (shouldShow != _showGradient) {
      setState(() {
        _showGradient = shouldShow;
      });
    }
  }

  void _onItemTap(int index) async {
    setState(() {
      _rippleIndex = index;
    });

    _rippleController.forward().then((_) {
      _rippleController.reset();
      setState(() {
        _rippleIndex = null;
      });
    });

    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 50));
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navHeight = 76.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          children: [
            // Gradient background fade (like ScrollableAppBar)
            if (widget.showGradientOnScroll)
              AnimatedOpacity(
                opacity: _showGradient ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: navHeight + bottomPadding + 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withAlpha(250),
                        theme.colorScheme.surface.withAlpha(230),
                        theme.colorScheme.surface.withAlpha(200),
                        theme.colorScheme.surface.withAlpha(160),
                        theme.colorScheme.surface.withAlpha(110),
                        theme.colorScheme.surface.withAlpha(60),
                        theme.colorScheme.surface.withAlpha(20),
                        theme.colorScheme.surface.withAlpha(0),
                      ],
                      stops: const [
                        0.0,
                        0.35,
                        0.5,
                        0.6,
                        0.68,
                        0.75,
                        0.82,
                        0.9,
                        0.96,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            // Floating navigation bar
            Positioned(
              bottom: bottomPadding + 5,
              left: 20,
              right: 20,
              child: Container(
                height: navHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.onSurface.withAlpha(15),
                      offset: const Offset(0, 8),
                      blurRadius: 32,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: theme.colorScheme.onSurface.withAlpha(5),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.08),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return _buildNavItem(index, theme);
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, ThemeData theme) {
    final isSelected = widget.selectedIndex == index;
    final isRippling = _rippleIndex == index;

    final icons = [
      CupertinoIcons.house_fill,
      CupertinoIcons.square_grid_2x2_fill,
      CupertinoIcons.lock_fill,
      CupertinoIcons.shield_fill,
      CupertinoIcons.wrench_fill,
    ];

    final outlineIcons = [
      CupertinoIcons.house,
      CupertinoIcons.square_grid_2x2,
      CupertinoIcons.lock,
      CupertinoIcons.shield,
      CupertinoIcons.wrench,
    ];

    return GestureDetector(
      onTap: () => _onItemTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tap ripple effect
            if (isRippling)
              Container(
                width: 56 * (1 + _rippleController.value * 0.2),
                height: 56 * (1 + _rippleController.value * 0.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(
                    0.2 * (1 - _rippleController.value),
                  ),
                ),
              ),
            // Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? icons[index] : outlineIcons[index],
                key: ValueKey('${index}_$isSelected'),
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
