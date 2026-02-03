import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/features/dashboard/features/vault/pages/_vault_item_detail_page.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_button.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_category_bottom_sheet.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_edit_dialog.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_slogan_section.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_password_health_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_categories_section.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_types_section.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVaultItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading passwords: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Available password categories for filtering
  final List<String> _categories = [
    'All',
    'Social',
    'Work',
    'Finance',
    'Shopping',
  ];

  // Available password types for filtering
  final List<String> _types = [
    'Login',
    'API Key',
    'Credit Card',
    'Note',
    'Identity',
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
            Container(
              color: theme.colorScheme.surface,
            ),
            // Scrollable content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              slivers: [
                // Top spacing for appbar
                SliverToBoxAdapter(
                  child: SizedBox(height: appBarHeight + MediaQuery.of(context).padding.top),
                ),
                // Welcome slogan section
                const SliverToBoxAdapter(child: VaultSloganSection()),
                // Horizontal scrollable categories with fade effect
                SliverToBoxAdapter(
                  child: VaultCategoriesSection(
                    categories: _categories,
                    onAddCategory: () => showAddCategoryBottomSheet(
                      wrapperScaffoldKey.currentState!.context,
                    ),
                    onCategoryTap: (category) {
                      // category tap
                    },
                  ),
                ),
            // Horizontal scrollable types with fade effect
            SliverToBoxAdapter(
              child: VaultTypesSection(
                types: _types,
                onAddType: () {
                  // Add type tap - can create similar bottom sheet for types
                },
                onTypeTap: (type) {
                  // type tap
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
                            item.passwordHealth == PasswordHealthStatus.strong,
                      )
                      .length,
                  weakCount: _vaultItems
                      .where(
                        (item) =>
                            item.passwordHealth == PasswordHealthStatus.weak,
                      )
                      .length,
                  reusedCount: _vaultItems
                      .where(
                        (item) =>
                            item.passwordHealth == PasswordHealthStatus.reused,
                      )
                      .length,
                ),
              ),
            ),

            // Passwords list
            _isLoading
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
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
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = _vaultItems[index];
                        return _buildPasswordItem(theme, item);
                      }, childCount: _vaultItems.length),
                    ),
                  ),
                // Bottom spacing for floating navigation bar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 64 + MediaQuery.of(context).padding.bottom + 32,
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
                icon: Icons.menu,
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
                  final result = await showVaultAddEditDialog(context);
                  if (result == true && mounted) {
                    // Password added successfully - reload data
                    _loadVaultItems();
                  }
                },
              ),
            ),          ],
        ),
      ),
    );
  }

  Widget _buildPasswordItem(ThemeData theme, VaultItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () async {
          final result = await Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => VaultItemDetailPage(vaultItem: item),
            ),
          );
          if (result == true && mounted) {
            // Item was deleted, reload list
            _loadVaultItems();
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(item.category),
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
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
              Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getHealthColor(item.passwordHealth).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
