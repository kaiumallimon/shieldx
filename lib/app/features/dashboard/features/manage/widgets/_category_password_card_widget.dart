import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/features/dashboard/features/vault/utils/_vault_item_helpers.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_decrypted_title_widget.dart';

class CategoryPasswordCardWidget extends StatelessWidget {
  final VaultItem item;
  final VoidCallback onUpdate;

  const CategoryPasswordCardWidget({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final healthColor = VaultItemHelpers.getHealthColor(context, item.passwordHealth);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            VaultItemHelpers.getCategoryIcon(item.category),
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: DecryptedTitleWidget(
                item: item,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (item.isFavorite)
              const Icon(
                CupertinoIcons.star_fill,
                size: 18,
                color: Colors.amber,
              ),
          ],
        ),
        subtitle: item.websiteUrl != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item.websiteUrl!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: healthColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: healthColor,
                  width: 1,
                ),
              ),
              child: Text(
                VaultItemHelpers.getHealthLabel(item.passwordHealth),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: healthColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        onTap: () async {
          final result = await context.push('/vault/item/${item.id}', extra: item);
          if (result == true) {
            onUpdate();
          }
        },
      ),
    );
  }
}
