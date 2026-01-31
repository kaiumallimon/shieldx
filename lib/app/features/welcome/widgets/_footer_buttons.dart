import 'package:flutter/material.dart';

class FooterButtons extends StatelessWidget {
  final PageController pageController;
  final int totalPages;
  final VoidCallback onGetStarted;
  final VoidCallback onNavigateToApp;

  const FooterButtons({
    super.key,
    required this.pageController,
    required this.totalPages,
    required this.onGetStarted,
    required this.onNavigateToApp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onGetStarted,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Get Started',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: () {
              final currentPage = pageController.hasClients
                  ? (pageController.page ?? 0).round()
                  : 0;
              if (currentPage < totalPages - 1) {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              } else {
                onNavigateToApp();
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              pageController.hasClients &&
              (pageController.page ?? 0).round() == totalPages - 1
                  ? 'Login'
                  : 'Next',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
