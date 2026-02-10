import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:toastification/toastification.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/core/services/encryption_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_edit_dialog.dart';
import 'package:shieldx/app/features/dashboard/features/vault/utils/_vault_item_helpers.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_info_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_password_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_notes_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_metadata_card.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';

// Top-level function for isolate-based decryption
class _DecryptionParams {
  final VaultItem item;
  final String masterPassword;

  _DecryptionParams({required this.item, required this.masterPassword});
}

class _DecryptionResult {
  final String? title;
  final String? username;
  final String? email;
  final String? password;
  final String? notes;
  final String? error;

  _DecryptionResult({
    this.title,
    this.username,
    this.email,
    this.password,
    this.notes,
    this.error,
  });
}

Future<_DecryptionResult> _decryptInIsolate(_DecryptionParams params) async {
  try {
    final item = params.item;
    final masterPassword = params.masterPassword;

    // Check if this is old base64-only encrypted data (no proper nonce)
    if (item.nonce.isEmpty || item.nonce.length < 16) {
      print('Old format detected, using base64 fallback');

      String? title;
      try {
        title = utf8.decode(base64Decode(item.title));
      } catch (e) {
        title = item.title;
      }

      VaultItemPayload? payload;
      try {
        final decryptedBytes = base64Decode(item.encryptedPayload);
        final decryptedString = utf8.decode(decryptedBytes);
        final payloadJson = jsonDecode(decryptedString) as Map<String, dynamic>;
        payload = VaultItemPayload.fromJson(payloadJson);
      } catch (e) {
        print('Base64 payload decryption failed: $e');
      }

      return _DecryptionResult(
        title: title,
        username: payload?.username,
        email: payload?.email,
        password: payload?.password,
        notes: payload?.notes,
      );
    }

    // The stored nonce is actually the salt used for key derivation
    final salt = EncryptionService.base64ToBytes(item.nonce);
    final encryptionKey = await EncryptionService.deriveKeyArgon2(
      masterPassword: masterPassword,
      salt: salt,
    );

    // Use the same salt as nonce for AES-GCM (as done during encryption)
    final nonce = salt;

    // Decrypt title
    String? title;
    try {
      final titleKey = encrypt.Key(encryptionKey);
      final titleIv = encrypt.IV(nonce);
      final titleEncrypter = encrypt.Encrypter(
        encrypt.AES(titleKey, mode: encrypt.AESMode.gcm),
      );
      final encryptedTitleData = encrypt.Encrypted.fromBase64(item.title);
      final decryptedBytes = titleEncrypter.decryptBytes(encryptedTitleData, iv: titleIv);
      title = utf8.decode(decryptedBytes);
    } catch (e) {
      print('Error decrypting title (trying fallback): $e');
      try {
        title = utf8.decode(base64Decode(item.title));
      } catch (e2) {
        title = item.title;
      }
    }

    // Decrypt payload
    VaultItemPayload? payload;
    try {
      payload = EncryptionService.decryptPayload(
        encryptedPayload: item.encryptedPayload,
        encryptionKey: encryptionKey,
        nonce: nonce,
      );
    } catch (payloadError) {
      print('Payload decryption failed, trying fallback: $payloadError');
      try {
        final decryptedBytes = base64Decode(item.encryptedPayload);
        final decryptedString = utf8.decode(decryptedBytes);
        final payloadJson = jsonDecode(decryptedString) as Map<String, dynamic>;
        payload = VaultItemPayload.fromJson(payloadJson);
      } catch (fallbackError) {
        print('Fallback also failed: $fallbackError');
        payload = null;
      }
    }

    return _DecryptionResult(
      title: title,
      username: payload?.username,
      email: payload?.email,
      password: payload?.password,
      notes: payload?.notes,
    );
  } catch (e) {
    print('Decryption error in isolate: $e');
    return _DecryptionResult(error: e.toString());
  }
}

class VaultItemDetailPage extends StatefulWidget {
  final String itemId;

  const VaultItemDetailPage({super.key, required this.itemId});

  @override
  State<VaultItemDetailPage> createState() => _VaultItemDetailPageState();
}

class _VaultItemDetailPageState extends State<VaultItemDetailPage> {
  final _supabaseService = SupabaseVaultService();
  final _authStorage = AuthStorageService();
  final ScrollController _scrollController = ScrollController();
  bool _isPasswordVisible = false;
  bool _isDeleting = false;
  bool _isLoadingDecryption = true;
  bool _isLoadingItem = true;
  VaultItem? _currentItem;

  // Decrypted payload data
  String? _decryptedTitle;
  String? _decryptedUsername;
  String? _decryptedEmail;
  String? _actualPassword;
  String? _decryptedNotes;

  @override
  void initState() {
    super.initState();
    // Fetch item and decrypt in background without blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItemAndDecrypt();
    });
  }

  Future<void> _loadItemAndDecrypt() async {
    try {
      // Fetch the item from database
      final item = await _supabaseService.getVaultItemById(widget.itemId);
      if (item == null) {
        if (mounted) {
          context.pop();
          toastification.show(
            context: context,
            title: const Text('Item not found'),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 2),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _currentItem = item;
          _isLoadingItem = false;
        });
      }

      // Now decrypt the data
      await _loadDecryptedData();
    } catch (e) {
      print('Error loading item: $e');
      if (mounted) {
        context.pop();
        toastification.show(
          context: context,
          title: Text('Error loading item: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDecryptedData() async {
    if (_currentItem == null) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _handleDecryptionError('User not authenticated');
        return;
      }

      final session = await _authStorage.getUserSession();
      final masterPassword = session?['userId'] ?? userId; // TODO: Use actual master password

      // Run decryption in separate isolate
      final result = await compute(
        _decryptInIsolate,
        _DecryptionParams(
          item: _currentItem!,
          masterPassword: masterPassword,
        ),
      );

      if (result.error != null) {
        _handleDecryptionError(result.error!);
        return;
      }

      if (mounted) {
        setState(() {
          _decryptedTitle = result.title;
          _decryptedUsername = result.username;
          _decryptedEmail = result.email;
          _actualPassword = result.password;
          _decryptedNotes = result.notes;
          _isLoadingDecryption = false;
        });
      }
    } catch (e) {
      print('Decryption error: $e');
      _handleDecryptionError(e.toString());
    }
  }

  void _handleDecryptionError(String error) {
    print('Decryption error: $error');
    if (mounted) {
      // Schedule toast to show after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          toastification.show(
            context: context,
            title: Text('Error decrypting data: $error'),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      });
    }
    if (mounted) {
      setState(() {
        _decryptedTitle = 'Encrypted Item';
        _decryptedUsername = null;
        _decryptedEmail = null;
        _actualPassword = null;
        _decryptedNotes = _currentItem!.notesPreview;
        _isLoadingDecryption = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentItem == null) return;
    try {
      final updated = _currentItem!.copyWith(
        isFavorite: !_currentItem!.isFavorite,
      );
      await _supabaseService.updateVaultItem(updated);
      setState(() => _currentItem = updated);
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Error: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _deleteItem() async {
    if (_currentItem == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Password'),
        content: Text(
          'Are you sure you want to delete "${_currentItem!.title}"?',
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
        await _supabaseService.deleteVaultItem(_currentItem!.id);
        if (mounted) {
          context.pop(true); // Return true to indicate deletion
          toastification.show(
            context: context,
            title: const Text('Password deleted successfully'),
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isDeleting = false);
          toastification.show(
            context: context,
            title: Text('Error: $e'),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      }
    }
  }

  Future<void> _editItem() async {
    if (_currentItem == null) return;
    final result = await showVaultAddEditDialog(
      context,
      existingItem: _currentItem,
    );

    if (result == true && mounted) {
      // Reload the item from database
      final updated = await _supabaseService.getVaultItemById(_currentItem!.id);
      if (updated != null) {
        setState(() => _currentItem = updated);
        _loadDecryptedData();
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    toastification.show(
      context: context,
      title: Text('$label copied to clipboard'),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;
    final appBarHeight = windowSize.height * 0.067;

    // Show loading state if item is not yet loaded
    if (_isLoadingItem || _currentItem == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Container(color: theme.colorScheme.surface),
              // Show shimmer placeholders instead of loading indicator
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: appBarHeight + MediaQuery.of(context).padding.top,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildShimmerCard(theme, height: 40),
                        const SizedBox(height: 24),
                        _buildShimmerCard(theme),
                        const SizedBox(height: 16),
                        _buildShimmerCard(theme),
                        const SizedBox(height: 16),
                        _buildShimmerCard(theme),
                        const SizedBox(height: 16),
                        _buildShimmerCard(theme),
                        const SizedBox(height: 16),
                        _buildShimmerCard(theme, height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
              ScrollableAppBar(
                scrollController: _scrollController,
                title: '',
                titleWidget: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                leading: CircularActionButton(
                  icon: LucideIcons.chevronLeft,
                  onTap: () => context.pop(),
                  scrollController: _scrollController,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                                    _currentItem!.category,
                                  ),
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  VaultItemHelpers.getCategoryName(
                                    _currentItem!.category,
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
                                _currentItem!.passwordHealth,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: VaultItemHelpers.getHealthColor(
                                  context,
                                  _currentItem!.passwordHealth,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              VaultItemHelpers.getHealthLabel(
                                _currentItem!.passwordHealth,
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: VaultItemHelpers.getHealthColor(
                                  context,
                                  _currentItem!.passwordHealth,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Show all shimmer placeholders while loading
                      if (_isLoadingDecryption) ...[
                        // Website shimmer
                        _buildShimmerCard(theme),
                        const SizedBox(height: 16),
                        // Username shimmer
                        _buildShimmerCard(theme),
                        const SizedBox(height: 16),
                        // Email shimmer
                        _buildShimmerCard(theme),
                        const SizedBox(height: 16),
                        // Password shimmer
                        _buildShimmerCard(theme),
                        const SizedBox(height: 16),
                        // Notes shimmer
                        _buildShimmerCard(theme, height: 100),
                        const SizedBox(height: 16),
                      ] else ...[
                        // Show all data together after decryption is complete
                        // Website
                        if (_currentItem!.websiteUrl != null) ...[
                          VaultInfoCard(
                            icon: CupertinoIcons.globe,
                            label: 'Website',
                            value: _currentItem!.websiteUrl!,
                            onCopy: () => _copyToClipboard(
                              _currentItem!.websiteUrl!,
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
                      ],

                      // Metadata
                      VaultMetadataCard(item: _currentItem!),

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
              title: _decryptedTitle ?? '',
              titleWidget: _isLoadingDecryption
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 20,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  : null,
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
                      icon: _currentItem!.isFavorite
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

  Widget _buildShimmerCard(ThemeData theme, {double height = 60}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
