import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_edit_dialog.dart';
import 'package:shieldx/app/features/dashboard/features/vault/utils/_vault_item_helpers.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';

class CategoryDetailPage extends StatefulWidget {
  final String category;

  const CategoryDetailPage({super.key, required this.category});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final SupabaseVaultService _vaultService = SupabaseVaultService();
  bool _isLoading = true;
  List<VaultItem> _categoryPasswords = [];

  @override
  void initState() {
    super.initState();
    _loadCategoryPasswords();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryPasswords() async {
    setState(() => _isLoading = true);
    try {
      final allItems = await _vaultService.getAllVaultItems();
      final categoryEnum = _getCategoryEnum(widget.category);

      if (mounted) {
        setState(() {
          _categoryPasswords = allItems
              .where((item) => item.category == categoryEnum)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading passwords: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAddPasswordBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.95,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Expanded dialog content
                Flexible(
                  child: VaultAddEditDialog(
                    initialCategory: _getCategoryEnum(widget.category),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((result) {
      if (result == true && mounted) {
        // Reload passwords
        _loadCategoryPasswords();
      }
    });
  }

  CredentialCategory _getCategoryEnum(String category) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryName = _getCategoryDisplayName(widget.category);
    final windowSize = MediaQuery.of(context).size;
    final appBarHeight = windowSize.height * 0.067;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Background
            Container(color: theme.colorScheme.surface),
            // Scrollable content
            CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // iOS-style refresh control
                CupertinoSliverRefreshControl(
                  onRefresh: _loadCategoryPasswords,
                ),
                // Top spacing for appbar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: appBarHeight + MediaQuery.of(context).padding.top,
                  ),
                ),
                // Category header
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor(widget.category),
                          _getCategoryColor(widget.category).withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getCategoryIcon(widget.category),
                          size: 48,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          categoryName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_categoryPasswords.length} passwords',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Passwords list
                _isLoading
                    ? SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildShimmerPasswordCard(theme),
                            childCount: 5,
                          ),
                        ),
                      )
                    : _categoryPasswords.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.folder,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No passwords in this category',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first password',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _categoryPasswords[index];
                              return _buildPasswordCard(context, item);
                            },
                            childCount: _categoryPasswords.length,
                          ),
                        ),
                      ),
                // Bottom spacing
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 76 + MediaQuery.of(context).padding.bottom + 32,
                  ),
                ),
              ],
            ),
            // Scrollable AppBar
            ScrollableAppBar(
              title: categoryName,
              scrollController: _scrollController,
              leading: CircularActionButton(
                scrollController: _scrollController,
                icon: LucideIcons.arrowLeft,
                onTap: () => Navigator.of(context).pop(),
              ),
              trailing: CircularActionButton(
                backgroundColor: theme.colorScheme.primary,
                iconColor: theme.colorScheme.onPrimary,
                scrollController: _scrollController,
                icon: CupertinoIcons.add,
                onTap: _showAddPasswordBottomSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
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

  Widget _buildPasswordCard(BuildContext context, VaultItem item) {
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
              child: Text(
                item.title,
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
          if (result == true && mounted) {
            _loadCategoryPasswords();
          }
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
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

  Color _getCategoryColor(String category) {
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

  Widget _buildShimmerPasswordCard(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.secondary.withAlpha(25),
      highlightColor: theme.colorScheme.secondary.withAlpha(100),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
