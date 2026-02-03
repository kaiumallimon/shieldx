import 'package:flutter/material.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/features/dashboard/features/vault/utils/_vault_item_helpers.dart';

/// Metadata card displaying creation, modification, and last used dates
class VaultMetadataCard extends StatelessWidget {
  final VaultItem item;

  const VaultMetadataCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetadataRow(
            theme,
            'Created',
            VaultItemHelpers.formatDate(item.createdAt),
          ),
          const Divider(height: 24),
          _buildMetadataRow(
            theme,
            'Modified',
            VaultItemHelpers.formatDate(item.updatedAt),
          ),
          if (item.lastUsedAt != null) ...[
            const Divider(height: 24),
            _buildMetadataRow(
              theme,
              'Last Used',
              VaultItemHelpers.formatDate(item.lastUsedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
