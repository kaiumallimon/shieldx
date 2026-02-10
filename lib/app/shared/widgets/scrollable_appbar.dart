import 'package:flutter/material.dart';

class ScrollableAppBar extends StatefulWidget {
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final ScrollController scrollController;
  final bool showGradientOnScroll;

  const ScrollableAppBar({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    required this.scrollController,
    this.showGradientOnScroll = true,
  });

  @override
  State<ScrollableAppBar> createState() => _ScrollableAppBarState();
}

class _ScrollableAppBarState extends State<ScrollableAppBar> {
  bool _showGradient = false;

  @override
  void initState() {
    super.initState();
    if (widget.showGradientOnScroll) {
      widget.scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (widget.showGradientOnScroll) {
      widget.scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = widget.scrollController.offset > 0;
    if (shouldShow != _showGradient) {
      setState(() {
        _showGradient = shouldShow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;
    final appBarHeight = windowSize.height * 0.067;

    return Stack(
      children: [
        // Fade background - positioned behind with IgnorePointer
        if (widget.showGradientOnScroll)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                opacity: _showGradient ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: ClipRect(
                  child: Container(
                    height:
                        appBarHeight + MediaQuery.of(context).padding.top + 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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
          ),
        // Fixed AppBar (transparent) - in front with pointer events enabled
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: AbsorbPointer(
            absorbing: false,
            child: SizedBox(
              height: appBarHeight,
              child: Row(
                mainAxisAlignment: widget.title == null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                spacing: 8,
                children: [
                  if (widget.leading != null) widget.leading!,
                  if (widget.title != null)
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
