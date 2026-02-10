import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

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
    icon: Ionicons.home_outline,
    selectedIcon: Ionicons.home,
    label: 'Vault',
  ),
  NavItem(
    icon: Ionicons.folder_open_outline,
    selectedIcon: Ionicons.folder_open,
    label: 'Manage',
  ),
  NavItem(
    icon: Ionicons.key_outline,
    selectedIcon: Ionicons.key,
    label: 'Generate',
  ),
  NavItem(
    icon: Ionicons.shield_outline,
    selectedIcon: Ionicons.shield,
    label: 'Security',
  ),
  NavItem(
    icon: Ionicons.extension_puzzle_outline,
    selectedIcon: Ionicons.extension_puzzle,
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
    final totalHeight = navHeight + bottomPadding + 8;
    final fadeHeight = 60.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: totalHeight + fadeHeight,
        child: Stack(
          children: [
            // Permanent gradient background fade
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: true,
                child: ClipRect(
                  child: Container(
                    height: totalHeight + fadeHeight,
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
            ),
            // Regular bottom navigation bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AbsorbPointer(
                absorbing: false,
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(
                    bottom: bottomPadding,
                    top: 8,
                  ),
                  child: SizedBox(
                    height: navHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          // Sliding pill background
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubicEmphasized,
                            left: (MediaQuery.of(context).size.width - 32) /
                                  _navItems.length * widget.selectedIndex,
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 32) /
                                     _navItems.length,
                              height: navHeight,
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withAlpha(50),
                                  // borderRadius: BorderRadius.circular(16),
                                  shape: BoxShape.circle
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
          height: 72,
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
                    isSelected ? navItem.selectedIcon : navItem.icon,
                    size: 22,
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
  final IconData  selectedIcon;
  final String label;

  NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
