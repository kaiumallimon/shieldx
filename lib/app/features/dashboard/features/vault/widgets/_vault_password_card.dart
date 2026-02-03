import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Password field card with visibility toggle and copy functionality
class VaultPasswordCard extends StatelessWidget {
  final String? password;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;

  const VaultPasswordCard({
    super.key,
    required this.password,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.onCopy,
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
            children: [
              Icon(
                LucideIcons.key,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Password',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  isVisible ? (password ?? '••••••••••••') : '••••••••••••',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: isVisible ? 'monospace' : null,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
                tooltip: isVisible ? 'Hide' : 'Show',
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 20),
                onPressed: onCopy,
                tooltip: 'Copy',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
