import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shieldx/app/data/repositories/offline_vault_repository.dart';
import 'package:shieldx/app/data/local/local_database.dart';
import 'package:shieldx/app/data/local/local_vault_repository.dart';
import 'package:shieldx/app/core/services/isolate_encryption_service.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';

class AllPasswordsPage extends StatefulWidget {
  const AllPasswordsPage({super.key});

  @override
  State<AllPasswordsPage> createState() => _AllPasswordsPageState();
}

class _AllPasswordsPageState extends State<AllPasswordsPage> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _sortBy = 'recent'; // recent, name, category

  late final OfflineVaultRepository _vaultRepository;
  List<VaultItem> _passwords = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initRepository() async {
    try {
      final localDb = LocalDatabase();
      final localVaultRepo = LocalVaultRepository(localDb);
      final isolateEncryption = IsolateEncryptionService();

      _vaultRepository = OfflineVaultRepository(
        localRepo: localVaultRepo,
        encryptionService: isolateEncryption,
      );

      await _loadPasswords();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPasswords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current user ID from Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch all vault items
      final items = await _vaultRepository.getAllVaultItems(userId);

      setState(() {
        _passwords = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.lock,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                password.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (password.isFavorite)
              Icon(
                Icons.star,
                size: 18,
                color: Colors.amber,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (password.websiteUrl != null)
              Text(
                password.websiteUrl!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    password.category.toJson(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: healthColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _getHealthLabel(password.passwordHealth),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          LucideIcons.chevronRight,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onTap: () {
          // Navigate to password details page
        },
      ),
    );
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
    switch (health) {
      case PasswordHealthStatus.strong:
        return Colors.green;
      case PasswordHealthStatus.weak:
        return Colors.orange;
      case PasswordHealthStatus.reused:
        return Colors.red;
      case PasswordHealthStatus.breached:
        return Colors.red.shade900;
      case PasswordHealthStatus.expired:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
