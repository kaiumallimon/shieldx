import 'package:flutter/material.dart';

class WelcomeImageContainer extends StatelessWidget {
  final String imagePath;
  final bool isSmallScreen;

  const WelcomeImageContainer({
    super.key,
    required this.imagePath,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;

    final imageHeight = isSmallScreen
        ? windowSize.height * 0.35
        : windowSize.height * 0.4;

    return Container(
      constraints: BoxConstraints(
        maxWidth: windowSize.width > 600 ? 400 : double.infinity,
        maxHeight: imageHeight,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }
}
