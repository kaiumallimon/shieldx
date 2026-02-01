import 'package:flutter/material.dart';

class VaultPasswordHealthCard extends StatelessWidget {
  final int totalPasswords;
  final int safeCount;
  final int weakCount;
  final int reusedCount;

  const VaultPasswordHealthCard({
    super.key,
    required this.totalPasswords,
    required this.safeCount,
    required this.weakCount,
    required this.reusedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Health',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withAlpha(200),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withAlpha(120),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left column
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withAlpha(150),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Passwords',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondary.withAlpha(200),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$totalPasswords',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Image.asset('assets/images/happy-doodle.png', height: 150),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              // Right column - improved layout
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildStatRow(
                      context,
                      label: 'Safe',
                      count: safeCount,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      label: 'Weak',
                      count: weakCount,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      label: 'Reused',
                      count: reusedCount,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSecondary.withAlpha(230),
          ),
        ),
      ],
    );
  }
}
