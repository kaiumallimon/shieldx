import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:toastification/toastification.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_edit_dialog.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_decrypted_title_widget.dart';
import 'package:shieldx/app/features/dashboard/features/manage/widgets/_category_header_widget.dart';
import 'package:shieldx/app/features/dashboard/features/manage/widgets/_category_empty_state_widget.dart';
import 'package:shieldx/app/features/dashboard/features/manage/utils/_category_helpers.dart';
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
      final categoryEnum = CategoryHelpers.getCategoryEnum(widget.category);

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
        toastification.show(
          context: context,
          title: Text('Error loading passwords: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
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
                    initialCategory: CategoryHelpers.getCategoryEnum(widget.category),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryName = CategoryHelpers.getCategoryDisplayName(widget.category);
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
                  child: CategoryHeaderWidget(
                    categoryName: categoryName,
                    categoryIcon: CategoryHelpers.getCategoryIcon(widget.category),
                    categoryColor: CategoryHelpers.getCategoryColor(context, widget.category),
                    itemCount: _categoryPasswords.length,
                  ),
                ),
                // Passwords list
                _isLoading
                    ? SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildShimmerItem(theme),
                            childCount: 5,
                          ),
                        ),
                      )
                    : _categoryPasswords.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: CategoryEmptyStateWidget(),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  // Show title only before first item
                                  if (index == 0) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Available Passwords',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildPasswordItem(theme, _categoryPasswords[index]),
                                      ],
                                    );
                                  }
                                  return _buildPasswordItem(theme, _categoryPasswords[index]);
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

  Widget _buildShimmerItem(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.secondary.withAlpha(25),
        highlightColor: theme.colorScheme.secondary.withAlpha(100),
        child: ListTile(
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          title: Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            height: 12,
            width: 150,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          trailing: Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordItem(ThemeData theme, VaultItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () async {
        final result = await context.push('/vault/item/${item.id}', extra: item);
        // If item was deleted, reload the list
        if (result == true && mounted) {
          _loadCategoryPasswords();
        }
      },
      leading: item.iconUrl != null
          ? SizedBox(
              width: 56,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.secondary.withAlpha(50),
                    width: 2,
                  ),
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.iconUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(item.category),
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.secondary.withAlpha(50),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: theme.colorScheme.primary,
                size: 30,
              ),
            ),
      title: DecryptedTitleWidget(
        item: item,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: item.websiteUrl != null
          ? Text(
              item.websiteUrl!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.isFavorite)
            Icon(LucideIcons.star, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getHealthColor(
                item.passwordHealth,
              ).withAlpha(25),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: _getHealthColor(item.passwordHealth),
                width: 1,
              ),
            ),
            child: Text(
              _getHealthLabel(item.passwordHealth),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getHealthColor(item.passwordHealth),
                fontWeight: FontWeight.w600,
                fontSize: 10,
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

  Color _getHealthColor(PasswordHealthStatus status) {
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

  String _getHealthLabel(PasswordHealthStatus status) {
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


}
