import 'package:flutter/material.dart';

class PageIndicators extends StatelessWidget {
  final PageController pageController;
  final int pageCount;

  const PageIndicators({
    super.key,
    required this.pageController,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedBuilder(
          animation: pageController,
          builder: (context, child) {
            double selectedness = 0.0;
            if (pageController.hasClients &&
                pageController.position.hasContentDimensions) {
              final page = pageController.page ?? 0;
              selectedness = page - index;
              selectedness = (1.0 - (selectedness.abs().clamp(0.0, 1.0)));
            } else {
              selectedness = index == 0 ? 1.0 : 0.0;
            }

            final isActive = selectedness > 0.5;
            final width = isActive ? 24.0 : 8.0;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: width,
              height: 8.0,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }
}
