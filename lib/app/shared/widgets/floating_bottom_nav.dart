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
          // Floating bottom navigation bar with blur
          Positioned(
            bottom: bottomPadding ,
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
                    padding: const EdgeInsets.all(
                      8
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        _navItems.length,
                        (index) => _buildNavItem(index, theme),
                      ),
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
      child: InkWell(
        onTap: () => widget.onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    navItem.icon,
                    size: 24,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  // if (isSelected) ...[
                  //   const SizedBox(height: 4),
                  //   Text(
                  //     navItem.label,
                  //     style: TextStyle(
                  //       fontSize: 11,
                  //       fontWeight: FontWeight.w600,
                  //       color: theme.colorScheme.onPrimary,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
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
