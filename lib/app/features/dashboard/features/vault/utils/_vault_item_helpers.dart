import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';

/// Helper class for vault item UI utilities
class VaultItemHelpers {
  /// Get icon for credential category
  static IconData getCategoryIcon(CredentialCategory category) {
    switch (category) {
      case CredentialCategory.login:
        return CupertinoIcons.lock_shield;
      case CredentialCategory.creditCard:
        return CupertinoIcons.creditcard;
      case CredentialCategory.identity:
        return CupertinoIcons.person_badge_plus;
      case CredentialCategory.secureNote:
        return CupertinoIcons.doc_text;
      case CredentialCategory.apiKey:
        return CupertinoIcons.lock_rotation;
      case CredentialCategory.bankAccount:
        return CupertinoIcons.building_2_fill;
      case CredentialCategory.cryptoWallet:
        return CupertinoIcons.money_dollar_circle;
      case CredentialCategory.sshKey:
        return CupertinoIcons.command;
      case CredentialCategory.license:
        return CupertinoIcons.doc_on_clipboard;
      case CredentialCategory.custom:
        return CupertinoIcons.square_favorites_alt;
    }
  }

  /// Get human-readable category name
  static String getCategoryName(CredentialCategory category) {
    return category.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();
  }

  /// Get color for password health status
  static Color getHealthColor(
    BuildContext context,
    PasswordHealthStatus status,
  ) {
    final theme = Theme.of(context);
    switch (status) {
      case PasswordHealthStatus.strong:
        return theme.colorScheme.primary;
      case PasswordHealthStatus.weak:
        return theme.colorScheme.tertiary;
      case PasswordHealthStatus.reused:
      case PasswordHealthStatus.breached:
        return theme.colorScheme.error;
      case PasswordHealthStatus.expired:
        return theme.colorScheme.error;
      case PasswordHealthStatus.unknown:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  /// Get label for password health status
  static String getHealthLabel(PasswordHealthStatus status) {
    switch (status) {
      case PasswordHealthStatus.strong:
        return 'Strong';
      case PasswordHealthStatus.weak:
        return 'Weak';
      case PasswordHealthStatus.reused:
        return 'Reused';
      case PasswordHealthStatus.breached:
        return 'Breached';
      case PasswordHealthStatus.expired:
        return 'Expired';
      case PasswordHealthStatus.unknown:
        return 'Unknown';
    }
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
