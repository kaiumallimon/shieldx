import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PasswordLengthSlider extends StatelessWidget {
  final double passwordLength;
  final ValueChanged<double> onLengthChanged;
  final VoidCallback onGeneratePassword;

  const PasswordLengthSlider({
    super.key,
    required this.passwordLength,
    required this.onLengthChanged,
    required this.onGeneratePassword,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Length',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${passwordLength.round()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoSlider(
              value: passwordLength,
              min: 8,
              max: 32,
              divisions: 24,
              onChanged: onLengthChanged,
              onChangeEnd: (_) => onGeneratePassword(),
            ),
          ),
        ],
      ),
    );
  }
}