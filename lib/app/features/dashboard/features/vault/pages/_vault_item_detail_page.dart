import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_edit_dialog.dart';

class VaultItemDetailPage extends StatefulWidget {
  final VaultItem vaultItem;

  const VaultItemDetailPage({super.key, required this.vaultItem});

  @override
  State<VaultItemDetailPage> createState() => _VaultItemDetailPageState();
}

class _VaultItemDetailPageState extends State<VaultItemDetailPage> {
  final _supabaseService = SupabaseVaultService();
  bool _isPasswordVisible = false;
  bool _isDeleting = false;
  late VaultItem _currentItem;

  // TODO: Decrypt payload properly
  String? _decryptedUsername;
  String? _decryptedEmail;
  String? _decryptedPassword;
  String? _decryptedNotes;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.vaultItem;
    _loadDecryptedData();
  }

  void _loadDecryptedData() {
    // TODO: Implement proper decryption
    // For now, just showing placeholder data
    setState(() {
      _decryptedUsername = 'username@example.com';
      _decryptedEmail = 'user@example.com';
      _decryptedPassword = '••••••••••••';
      _decryptedNotes = _currentItem.notesPreview;
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      final updated = _currentItem.copyWith(isFavorite: !_currentItem.isFavorite);
      await _supabaseService.updateVaultItem(updated);
      setState(() => _currentItem = updated);
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Password'),
        content: Text('Are you sure you want to delete "${_currentItem.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        await _supabaseService.deleteVaultItem(_currentItem.id);
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password deleted successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _editItem() async {
    final result = await showVaultAddEditDialog(
      context,
      existingItem: _currentItem,
    );

    if (result == true && mounted) {
      // Reload the item from database
      final updated = await _supabaseService.getVaultItemById(_currentItem.id);
      if (updated != null) {
        setState(() => _currentItem = updated);
        _loadDecryptedData();
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(_currentItem.title),
        actions: [
          IconButton(
            icon: Icon(
              _currentItem.isFavorite ? CupertinoIcons.star_fill : CupertinoIcons.star,
              color: _currentItem.isFavorite ? Colors.amber : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            onPressed: _editItem,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: _isDeleting ? null : _deleteItem,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Category badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(_currentItem.category),
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCategoryName(_currentItem.category),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getHealthColor(_currentItem.passwordHealth).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getHealthColor(_currentItem.passwordHealth),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getHealthLabel(_currentItem.passwordHealth),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getHealthColor(_currentItem.passwordHealth),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Website
          if (_currentItem.websiteUrl != null) ...[
            _buildInfoCard(
              theme,
              icon: CupertinoIcons.globe,
              label: 'Website',
              value: _currentItem.websiteUrl!,
              onCopy: () => _copyToClipboard(_currentItem.websiteUrl!, 'Website URL'),
            ),
            const SizedBox(height: 16),
          ],

          // Username
          if (_decryptedUsername != null) ...[
            _buildInfoCard(
              theme,
              icon: CupertinoIcons.person,
              label: 'Username',
              value: _decryptedUsername!,
              onCopy: () => _copyToClipboard(_decryptedUsername!, 'Username'),
            ),
            const SizedBox(height: 16),
          ],

          // Email
          if (_decryptedEmail != null) ...[
            _buildInfoCard(
              theme,
              icon: CupertinoIcons.mail,
              label: 'Email',
              value: _decryptedEmail!,
              onCopy: () => _copyToClipboard(_decryptedEmail!, 'Email'),
            ),
            const SizedBox(height: 16),
          ],

          // Password
          if (_decryptedPassword != null) ...[
            _buildPasswordCard(theme),
            const SizedBox(height: 16),
          ],

          // Notes
          if (_decryptedNotes != null && _decryptedNotes!.isNotEmpty) ...[
            _buildNotesCard(theme),
            const SizedBox(height: 16),
          ],

          // Metadata
          _buildMetadataCard(theme),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 20),
                onPressed: onCopy,
                tooltip: 'Copy',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.lock, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Password',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _isPasswordVisible ? _decryptedPassword! : '••••••••••••',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: _isPasswordVisible ? 'monospace' : null,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  size: 20,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                tooltip: _isPasswordVisible ? 'Hide' : 'Show',
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 20),
                onPressed: () => _copyToClipboard(_decryptedPassword!, 'Password'),
                tooltip: 'Copy',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.doc_text, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _decryptedNotes!,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetadataRow(theme, 'Created', _formatDate(_currentItem.createdAt)),
          const Divider(height: 24),
          _buildMetadataRow(theme, 'Modified', _formatDate(_currentItem.updatedAt)),
          if (_currentItem.lastUsedAt != null) ...[
            const Divider(height: 24),
            _buildMetadataRow(theme, 'Last Used', _formatDate(_currentItem.lastUsedAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
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
    return category.name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    ).trim();
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
