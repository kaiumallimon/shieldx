import 'package:flutter/material.dart';

class WelcomeTitle extends StatelessWidget {
  final String title;

  const WelcomeTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: windowSize.width > 600 ? 60 : 10,
      ),
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
