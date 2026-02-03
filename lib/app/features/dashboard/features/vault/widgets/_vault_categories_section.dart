import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';

class VaultCategoriesSection extends StatelessWidget {
  /// List of categories to display
  final List<CredentialCategory> categories;

  /// Callback when a category chip is tapped, receives the category
  final Function(CredentialCategory)? onCategoryTap;

  const VaultCategoriesSection({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Row(
        children: [
          // Fixed "Categories" label
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              'Categories',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Scrollable categories with fade effect
          Expanded(
            child: ShaderMask(
              // Creates a gradient fade on both edges (left 5%, right 15%)
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.05, 0.85, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                    categories.length,
                    (index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () => onCategoryTap?.call(category),
                        child: Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          // margin: const EdgeInsets.only(right: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(50),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                size: 18,
                                color: theme.colorScheme.onSurface.withAlpha(128),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getCategoryName(category),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface.withAlpha(128),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(CredentialCategory category) {
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

  String _getCategoryName(CredentialCategory category) {
    switch (category) {
      case CredentialCategory.login:
        return 'Login';
      case CredentialCategory.creditCard:
        return 'Credit Card';
      case CredentialCategory.identity:
        return 'Identity';
      case CredentialCategory.secureNote:
        return 'Secure Note';
      case CredentialCategory.apiKey:
        return 'API Key';
      case CredentialCategory.bankAccount:
        return 'Bank Account';
      case CredentialCategory.cryptoWallet:
        return 'Crypto Wallet';
      case CredentialCategory.sshKey:
        return 'SSH Key';
      case CredentialCategory.license:
        return 'License';
      case CredentialCategory.custom:
        return 'Custom';
    }
  }
}
