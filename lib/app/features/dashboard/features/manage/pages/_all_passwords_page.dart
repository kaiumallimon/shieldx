import 'package:flutter/material.dart';
import 'package:shieldx/app/data/repositories/offline_vault_repository.dart';
import 'package:shieldx/app/data/local/local_database.dart';
import 'package:shieldx/app/data/local/local_vault_repository.dart';
import 'package:shieldx/app/core/services/isolate_encryption_service.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllPasswordsPage extends StatefulWidget {
  const AllPasswordsPage({super.key});

  @override
  State<AllPasswordsPage> createState() => _AllPasswordsPageState();
}

class _AllPasswordsPageState extends State<AllPasswordsPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Passwords'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPasswords,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'recent', child: Text('Recently Used')),
              const PopupMenuItem(value: 'name', child: Text('Name')),
              const PopupMenuItem(value: 'category', child: Text('Category')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
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
                        style: theme.textTheme.bodySmall,
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
                )
              : Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search passwords...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Passwords list
          Expanded(
            child: _filteredPasswords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No passwords found',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredPasswords.length,
                    itemBuilder: (context, index) {
                      final password = _filteredPasswords[index];
                      return _buildPasswordCard(context, password);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard(BuildContext context, VaultItem password) {
    final theme = Theme.of(context);
    final healthColor = _getHealthColor(password.passwordHealth);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.lock,
            color: theme.colorScheme.primary,
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
              Text(password.websiteUrl!),
            const SizedBox(height: 4),
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
                    style: theme.textTheme.bodySmall,
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
                  password.passwordHealth.toJson().toUpperCase(),
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
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onTap: () {
          // Navigate to password details page
        },
      ),
    );
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
