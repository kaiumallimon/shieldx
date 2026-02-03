import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:toastification/toastification.dart';

class AllPasswordsPage extends StatefulWidget {
  const AllPasswordsPage({super.key});

  @override
  State<AllPasswordsPage> createState() => _AllPasswordsPageState();
}

class _AllPasswordsPageState extends State<AllPasswordsPage> {
  final ScrollController _scrollController = ScrollController();
  final SupabaseVaultService _vaultService = SupabaseVaultService();
  String _searchQuery = '';
  String _sortBy = 'recent'; // recent, name, category

  List<VaultItem> _passwords = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPasswords() async {
    setState(() => _isLoading = true);
    try {
      final items = await _vaultService.getAllVaultItems();
      if (mounted) {
        setState(() {
          _passwords = items;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        toastification.show(
          context: context,
          title: Text('Error loading passwords: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  List<VaultItem> get _filteredPasswords {
    var filtered = _passwords.where((p) {
      final title = p.title.toLowerCase();
      final query = _searchQuery.toLowerCase();
      final notesPreview = p.notesPreview?.toLowerCase() ?? '';
      return title.contains(query) || notesPreview.contains(query);
    }).toList();

    // Sort
    if (_sortBy == 'name') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'category') {
      filtered.sort((a, b) => a.category.toJson().compareTo(b.category.toJson()));
    } else {
      filtered.sort((a, b) {
        final aTime = a.lastUsedAt ?? a.updatedAt;
        final bTime = b.lastUsedAt ?? b.updatedAt;
        return bTime.compareTo(aTime);
      });
    }

    return filtered;
  }

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
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top spacing for appbar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: appBarHeight + MediaQuery.of(context).padding.top,
                  ),
                ),
                // Content
                _isLoading
                    ? SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : _error != null
                        ? SliverFillRemaining(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error loading passwords',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _error!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton.icon(
                                      onPressed: _loadPasswords,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: Column(
                              children: [
                                // Search bar
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search passwords...',
                                      prefixIcon: const Icon(LucideIcons.search),
                                      filled: true,
                                      fillColor: theme.colorScheme.surfaceContainerHighest,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                // Passwords list
                                _filteredPasswords.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                LucideIcons.searchX,
                                                size: 64,
                                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'No passwords found',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _searchQuery.isNotEmpty
                                                    ? 'Try a different search term'
                                                    : 'Add your first password to get started',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        child: Column(
                                          children: _filteredPasswords
                                              .map((password) => _buildPasswordCard(context, password))
                                              .toList(),
                                        ),
                                      ),
                                const SizedBox(height: 20),
                                // Bottom spacing for floating navigation bar
                                SizedBox(
                                  height: 76 + MediaQuery.of(context).padding.bottom + 32,
                                ),
                              ],
                            ),
                          ),
              ],
            ),
            // ScrollableAppBar
            ScrollableAppBar(
              leading: CircularActionButton(
                icon: LucideIcons.chevronLeft,
                onTap: () {
                  context.pop();
                },
                scrollController: _scrollController,
              ),
              scrollController: _scrollController,
              title: 'All Passwords',
              trailing: CircularActionButton(
                icon: LucideIcons.refreshCw,
                onTap: _loadPasswords,
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard(BuildContext context, VaultItem password) {
    final theme = Theme.of(context);
    final healthColor = _getHealthColor(password.passwordHealth);

    return GestureDetector(
      onTap: () {
        context.push('/vault/item/${password.id}', extra: password);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Leading icon/logo
            password.iconUrl != null
                ? SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        password.iconUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(password.category),
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 24,
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
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(password.category),
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          password.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (password.isFavorite)
                        Icon(
                          CupertinoIcons.star_fill,
                          color: Colors.amber,
                          size: 20,
                        ),
                    ],
                  ),
                  if (password.websiteUrl != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      password.websiteUrl!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Health badge
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
                _getHealthLabel(password.passwordHealth),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: healthColor,
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

  String _getHealthLabel(PasswordHealthStatus health) {
    switch (health) {
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

  Color _getHealthColor(PasswordHealthStatus health) {
    final theme = Theme.of(context);
    switch (health) {
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
}
