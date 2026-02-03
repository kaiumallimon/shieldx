import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';

class CategoryHelpers {
  /// Convert category string to CredentialCategory enum
  static CredentialCategory getCategoryEnum(String category) {
    switch (category.toLowerCase()) {
      case 'login':
        return CredentialCategory.login;
      case 'credit_card':
        return CredentialCategory.creditCard;
      case 'identity':
        return CredentialCategory.identity;
      case 'secure_note':
        return CredentialCategory.secureNote;
      case 'api_key':
        return CredentialCategory.apiKey;
      case 'bank_account':
        return CredentialCategory.bankAccount;
      case 'crypto_wallet':
        return CredentialCategory.cryptoWallet;
      case 'ssh_key':
        return CredentialCategory.sshKey;
      case 'license':
        return CredentialCategory.license;
      case 'custom':
        return CredentialCategory.custom;
      default:
        return CredentialCategory.login;
    }
  }

  /// Get display name for category
  static String getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'login':
        return 'Login';
      case 'credit_card':
        return 'Credit Card';
      case 'identity':
        return 'Identity';
      case 'secure_note':
        return 'Secure Note';
      case 'api_key':
        return 'API Key';
      case 'bank_account':
        return 'Bank Account';
      case 'crypto_wallet':
        return 'Crypto Wallet';
      case 'ssh_key':
        return 'SSH Key';
      case 'license':
        return 'License';
      case 'custom':
        return 'Custom';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }

  /// Get icon for category
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'login':
        return CupertinoIcons.lock_shield;
      case 'credit_card':
        return CupertinoIcons.creditcard;
      case 'identity':
        return CupertinoIcons.person_badge_plus;
      case 'secure_note':
        return CupertinoIcons.doc_text;
      case 'api_key':
        return CupertinoIcons.lock_rotation;
      case 'bank_account':
        return CupertinoIcons.building_2_fill;
      case 'crypto_wallet':
        return CupertinoIcons.money_dollar_circle;
      case 'ssh_key':
        return CupertinoIcons.command;
      case 'license':
        return CupertinoIcons.doc_on_clipboard;
      case 'custom':
        return CupertinoIcons.square_favorites_alt;
      default:
        return CupertinoIcons.folder;
    }
  }

  /// Get color for category
  static Color getCategoryColor(BuildContext context, String category) {
    final theme = Theme.of(context);
    switch (category.toLowerCase()) {
      case 'login':
        return theme.colorScheme.primary;
      case 'credit_card':
        return theme.colorScheme.secondary;
      case 'identity':
        return theme.colorScheme.tertiary;
      case 'secure_note':
        return theme.colorScheme.error;
      case 'api_key':
        return theme.colorScheme.primary;
      case 'bank_account':
        return theme.colorScheme.secondary;
      case 'crypto_wallet':
        return theme.colorScheme.tertiary;
      case 'ssh_key':
        return theme.colorScheme.primary;
      case 'license':
        return theme.colorScheme.secondary;
      case 'custom':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.primary;
    }
  }
}
