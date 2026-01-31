import 'package:flutter/material.dart';

class WelcomeDescription extends StatelessWidget {
  final String description;

  const WelcomeDescription({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: windowSize.width > 600 ? 40 : 0,
      ),
      child: Text(
        description,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          height: 1.5,
        ),
        textAlign: TextAlign.center,
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
