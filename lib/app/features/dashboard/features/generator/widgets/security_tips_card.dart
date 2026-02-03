import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SecurityTipsCard extends StatelessWidget {
  final bool memorableMode;

  const SecurityTipsCard({
    super.key,
    required this.memorableMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.lightbulb,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Security Tips',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getTips().map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTips() {
    if (memorableMode) {
      return [
        'Memorable passwords are easier to remember',
        'Use 3-4 words for better security',
        'Still maintain uniqueness across accounts',
      ];
    } else {
      return [
        'Use at least 12-16 characters',
        'Mix all character types for strength',
        'Never reuse passwords',
        'Store passwords securely',
      ];
    }
  }
}