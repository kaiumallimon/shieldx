import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_edit_dialog.dart';
import 'package:shieldx/app/features/dashboard/features/vault/services/_vault_encryption_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/utils/_vault_item_helpers.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_info_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_password_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_notes_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_metadata_card.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';

class VaultItemDetailPage extends StatefulWidget {
  final VaultItem vaultItem;

  const VaultItemDetailPage({super.key, required this.vaultItem});

  @override
  State<VaultItemDetailPage> createState() => _VaultItemDetailPageState();
}

class _VaultItemDetailPageState extends State<VaultItemDetailPage> {
  final _supabaseService = SupabaseVaultService();
  final ScrollController _scrollController = ScrollController();
  bool _isPasswordVisible = false;
  bool _isDeleting = false;
  late VaultItem _currentItem;

  // Decrypted payload data
  String? _decryptedUsername;
  String? _decryptedEmail;
  String? _actualPassword;
  String? _decryptedNotes;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.vaultItem;
    _loadDecryptedData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDecryptedData() {
    try {
      // Decrypt the payload using encryption service
      final payload = VaultEncryptionService.decryptPayload(
        _currentItem.encryptedPayload,
      );

      if (payload != null) {
        setState(() {
          _decryptedUsername = payload.username;
          _decryptedEmail = payload.email;
          _actualPassword = payload.password;
          _decryptedNotes = payload.notes;
        });
      } else {
        _handleDecryptionError('Failed to decrypt payload');
      }
    } catch (e) {
      _handleDecryptionError(e.toString());
    }
  }

  void _handleDecryptionError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error decrypting data: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    setState(() {
      _decryptedUsername = null;
      _decryptedEmail = null;
      _actualPassword = null;
      _decryptedNotes = _currentItem.notesPreview;
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      final updated = _currentItem.copyWith(
        isFavorite: !_currentItem.isFavorite,
      );
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
        content: Text(
          'Are you sure you want to delete "${_currentItem.title}"?',
        ),
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
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Category badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  VaultItemHelpers.getCategoryIcon(
                                    _currentItem.category,
                                  ),
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  VaultItemHelpers.getCategoryName(
                                    _currentItem.category,
                                  ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: VaultItemHelpers.getHealthColor(
                                context,
                                _currentItem.passwordHealth,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: VaultItemHelpers.getHealthColor(
                                  context,
                                  _currentItem.passwordHealth,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              VaultItemHelpers.getHealthLabel(
                                _currentItem.passwordHealth,
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: VaultItemHelpers.getHealthColor(
                                  context,
                                  _currentItem.passwordHealth,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Website
                      if (_currentItem.websiteUrl != null) ...[
                        VaultInfoCard(
                          icon: CupertinoIcons.globe,
                          label: 'Website',
                          value: _currentItem.websiteUrl!,
                          onCopy: () => _copyToClipboard(
                            _currentItem.websiteUrl!,
                            'Website URL',
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Username
                      if (_decryptedUsername != null) ...[
                        VaultInfoCard(
                          icon: CupertinoIcons.person,
                          label: 'Username',
                          value: _decryptedUsername!,
                          onCopy: () =>
                              _copyToClipboard(_decryptedUsername!, 'Username'),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email
                      if (_decryptedEmail != null) ...[
                        VaultInfoCard(
                          icon: CupertinoIcons.mail,
                          label: 'Email',
                          value: _decryptedEmail!,
                          onCopy: () =>
                              _copyToClipboard(_decryptedEmail!, 'Email'),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Password
                      if (_actualPassword != null) ...[
                        VaultPasswordCard(
                          password: _actualPassword,
                          isVisible: _isPasswordVisible,
                          onToggleVisibility: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                          onCopy: () =>
                              _copyToClipboard(_actualPassword!, 'Password'),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Notes
                      if (_decryptedNotes != null &&
                          _decryptedNotes!.isNotEmpty) ...[
                        VaultNotesCard(notes: _decryptedNotes!),
                        const SizedBox(height: 16),
                      ],

                      // Metadata
                      VaultMetadataCard(item: _currentItem),

                      const SizedBox(height: 20),
                      // Bottom spacing for footer
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 90,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            // ScrollableAppBar
            ScrollableAppBar(
              scrollController: _scrollController,
              title: _currentItem.title,
              leading: CircularActionButton(
                icon: LucideIcons.chevronLeft,
                onTap: () {
                  context.pop();
                },
                scrollController: _scrollController,
              ),
            ),
            // Action buttons footer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.onSurface.withAlpha(25),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularActionButton(
                      onTap: _toggleFavorite,
                      icon: _currentItem.isFavorite
                          ? Icons.star
                          : Icons.star_border,
                      scrollController: _scrollController,
                    ),
                    const SizedBox(width: 12),
                    CircularActionButton(
                      onTap: _editItem,
                      icon: LucideIcons.edit3,
                      scrollController: _scrollController,
                    ),
                    const SizedBox(width: 12),
                    CircularActionButton(
                      onTap: ()async {
                        if (!_isDeleting) {
                          await _deleteItem();
                        }
                      },
                      icon: LucideIcons.trash,
                      scrollController: _scrollController,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
