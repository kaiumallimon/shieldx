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

class _FloatingBottomNavState extends State<FloatingBottomNav> {
  bool _showGradient = false;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItem(
      icon: Icons.grid_view_rounded,
      label: 'Manage',
    ),
    NavItem(
      icon: Icons.vpn_key_rounded,
      label: 'Generate',
    ),
    NavItem(
      icon: Icons.security_rounded,
      label: 'Security',
    ),
    NavItem(
      icon: Icons.extension_rounded,
      label: 'Tools',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null && widget.showGradientOnScroll) {
      widget.scrollController!.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null && widget.showGradientOnScroll) {
      widget.scrollController!.removeListener(_onScroll);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navHeight = 72.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Stack(
        children: [
          // Gradient background fade (like ScrollableAppBar)
          if (widget.showGradientOnScroll)
            AnimatedOpacity(
              opacity: _showGradient ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                child: Container(
                  height: navHeight + bottomPadding + 100,
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
            ),
          // Permanent fade below navbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: navHeight + bottomPadding + 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withAlpha(0),
                      theme.colorScheme.surface.withAlpha(10),
                      theme.colorScheme.surface.withAlpha(30),
                      theme.colorScheme.surface.withAlpha(60),
                      theme.colorScheme.surface.withAlpha(100),
                      theme.colorScheme.surface.withAlpha(150),
                      theme.colorScheme.surface.withAlpha(200),
                      theme.colorScheme.surface.withAlpha(240),
                      theme.colorScheme.surface,
                      theme.colorScheme.surface,
                    ],
                    stops: const [
                      0.0,
                      0.1,
                      0.2,
                      0.3,
                      0.4,
                      0.5,
                      0.6,
                      0.75,
                      0.85,
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating bottom navigation bar with blur
          Positioned(
            bottom: bottomPadding + 8,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.onSurface.withAlpha(20),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 13.0, sigmaY: 13.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withAlpha(20),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        // Sliding pill background
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubicEmphasized,
                          left: (MediaQuery.of(context).size.width - 32 - 16) /
                                _navItems.length * widget.selectedIndex,
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 32 - 16) /
                                   _navItems.length,
                            height: 64,
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withAlpha(30),
                                borderRadius: BorderRadius.circular(92),
                              ),
                            ),
                          ),
                        ),
                        // Nav items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            _navItems.length,
                            (index) => _buildNavItem(index, theme),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, ThemeData theme) {
    final isSelected = widget.selectedIndex == index;
    final navItem = _navItems[index];

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onItemTapped(index),
        child: Container(
          height: 64,
          color: Colors.transparent,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 1.0,
                end: isSelected ? 1.15 : 1.0,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    navItem.icon,
                    size: 26,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(128),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({
    required this.icon,
    required this.label,
  });
}
