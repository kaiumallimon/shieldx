import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_edit_dialog.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_slogan_section.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_password_health_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_categories_section.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  // Service for managing authentication and user session data
  final AuthStorageService _authStorage = AuthStorageService();
  final SupabaseVaultService _vaultService = SupabaseVaultService();
  final ScrollController _scrollController = ScrollController();

  // User profile information
  String? userName;
  String? avatarUrl;

  // Vault items
  List<VaultItem> _vaultItems = [];
  bool _isLoading = true;

  // Realtime subscription
  RealtimeChannel? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVaultItems();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _realtimeSubscription?.unsubscribe();
    super.dispose();
  }

  /// Set up realtime subscription for vault items
  void _setupRealtimeSubscription() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _realtimeSubscription = Supabase.instance.client
        .channel('vault_items')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vault_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Reload vault items when any change occurs
            _loadVaultItems();
          },
        )
        .subscribe();
  }

  /// Fetches user session data from storage and updates the UI
  Future<void> _loadUserData() async {
    final session = await _authStorage.getUserSession();
    print(session);
    if (session != null && mounted) {
      setState(() {
        userName = session['name'] as String?;
        avatarUrl = session['avatar_url'] as String?;
      });
    }
  }

  /// Load vault items from database
  Future<void> _loadVaultItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _vaultService.getAllVaultItems();
      if (mounted) {
        setState(() {
          _vaultItems = items;
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

  /// Refresh vault items (for pull to refresh)
  Future<void> _refreshVaultItems() async {
    print('Refreshing vault items...');
    try {
      final items = await _vaultService.getAllVaultItems();
      if (mounted) {
        setState(() {
          _vaultItems = items;
        });
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Error refreshing passwords: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  // Available password categories for filtering
  final List<CredentialCategory> _categories = [
    CredentialCategory.login,
    CredentialCategory.creditCard,
    CredentialCategory.identity,
    CredentialCategory.secureNote,
    CredentialCategory.apiKey,
    CredentialCategory.bankAccount,
    CredentialCategory.cryptoWallet,
    CredentialCategory.sshKey,
    CredentialCategory.license,
    CredentialCategory.custom,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              slivers: [
                // Pull to refresh
                CupertinoSliverRefreshControl(
                  onRefresh: _refreshVaultItems,
                ),
                // Top spacing for appbar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: appBarHeight + MediaQuery.of(context).padding.top,
                  ),
                ),
                // Welcome slogan section
                const SliverToBoxAdapter(child: VaultSloganSection()),
                // Horizontal scrollable categories with fade effect
                SliverToBoxAdapter(
                  child: VaultCategoriesSection(
                    categories: _categories,
                    onCategoryTap: (category) {
                      context.push('/manage/category/${category.toJson()}');
                    },
                  ),
                ),
                // Password health statistics card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: VaultPasswordHealthCard(
                      totalPasswords: _vaultItems.length,
                      safeCount: _vaultItems
                          .where(
                            (item) =>
                                item.passwordHealth ==
                                PasswordHealthStatus.strong,
                          )
                          .length,
                      weakCount: _vaultItems
                          .where(
                            (item) =>
                                item.passwordHealth ==
                                PasswordHealthStatus.weak,
                          )
                          .length,
                      reusedCount: _vaultItems
                          .where(
                            (item) =>
                                item.passwordHealth ==
                                PasswordHealthStatus.reused,
                          )
                          .length,
                    ),
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
                    : _vaultItems.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  CupertinoIcons.lock_shield,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No passwords yet',
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
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            // Show title only before first item
                            if (index == 0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Recently Added Passwords',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildPasswordItem(theme, _vaultItems[index]),
                                ],
                              );
                            }
                            return _buildPasswordItem(theme, _vaultItems[index]);
                          }, childCount: _vaultItems.length > 10 ? 10 : _vaultItems.length),
                        ),
                      ),
                // Bottom spacing for floating navigation bar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 76 + MediaQuery.of(context).padding.bottom + 32,
                  ),
                ),
              ],
            ),
            // ScrollableAppBar
            ScrollableAppBar(
              // title: 'Vault',
              scrollController: _scrollController,
              leading: CircularActionButton(
                scrollController: _scrollController,
                icon: LucideIcons.menu,
                onTap: () {
                  wrapperScaffoldKey.currentState?.openDrawer();
                },
              ),
              trailing: CircularActionButton(
                backgroundColor: theme.colorScheme.primary,
                iconColor: theme.colorScheme.onPrimary,
                scrollController: _scrollController,
                icon: CupertinoIcons.add,
                onTap: () async {
                  final result = await showVaultAddEditDialog(wrapperScaffoldKey.currentState!.context);
                  if (result == true && mounted) {
                    // Password added successfully - reload data
                    _loadVaultItems();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sanitize URL to get domain for brandfetch

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
          _loadVaultItems();
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
      title: Text(
        item.title,
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
