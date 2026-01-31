import 'package:flutter/material.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SkipButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          'Skip',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
