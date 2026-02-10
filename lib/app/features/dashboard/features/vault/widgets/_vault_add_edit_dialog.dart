import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/core/services/password_generator_service.dart';
import 'package:shieldx/app/core/services/encryption_service.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class VaultAddEditDialog extends StatefulWidget {
  final VaultItem? existingItem;
  final CredentialCategory? initialCategory;

  const VaultAddEditDialog({
    super.key,
    this.existingItem,
    this.initialCategory,
  });

  @override
  State<VaultAddEditDialog> createState() => _VaultAddEditDialogState();
}

class _VaultAddEditDialogState extends State<VaultAddEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseVaultService();
  final _authStorage = AuthStorageService();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _websiteController;
  late TextEditingController _notesController;

  // State
  late CredentialCategory _selectedCategory;
  bool _isPasswordVisible = false;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.initialCategory ??
        widget.existingItem?.category ??
        CredentialCategory.login;
    _isFavorite = widget.existingItem?.isFavorite ?? false;

    // Initialize all controllers immediately to avoid LateInitializationError
    _titleController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _websiteController = TextEditingController(
      text: widget.existingItem?.websiteUrl,
    );
    _notesController = TextEditingController(
      text: widget.existingItem?.notesPreview,
    );

    // Decrypt existing data if editing
    _initializeControllersAsync();
  }

  Future<void> _initializeControllersAsync() async {
    if (widget.existingItem != null) {
      try {
        // Get user's master password from secure storage
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          final session = await _authStorage.getUserSession();
          final masterPassword = session?['userId'] ?? userId; // TODO: Use actual master password

          // Derive encryption key
          final salt = EncryptionService.base64ToBytes(widget.existingItem!.nonce);
          final encryptionKey = await EncryptionService.deriveKeyArgon2(
            masterPassword: masterPassword,
            salt: salt,
          );

          // Decrypt title
          String decryptedTitle = '';
          try {
            final titleKey = encrypt.Key(encryptionKey);
            final titleIv = encrypt.IV(salt);
            final titleEncrypter = encrypt.Encrypter(
              encrypt.AES(titleKey, mode: encrypt.AESMode.gcm),
            );
            final encryptedTitleData = encrypt.Encrypted.fromBase64(widget.existingItem!.title);
            final decryptedBytes = titleEncrypter.decryptBytes(encryptedTitleData, iv: titleIv);
            decryptedTitle = utf8.decode(decryptedBytes);
          } catch (e) {
            print('Error decrypting title: $e');
            decryptedTitle = widget.existingItem!.title; // Fallback to original
          }

          // Decrypt payload if exists
          VaultItemPayload? payload;
          if (widget.existingItem!.encryptedPayload.isNotEmpty) {
            final nonce = salt; // Reuse salt as nonce for simplicity (should be separate)
            payload = EncryptionService.decryptPayload(
              encryptedPayload: widget.existingItem!.encryptedPayload,
              encryptionKey: encryptionKey,
              nonce: nonce,
            );
          }

          setState(() {
            _titleController.text = decryptedTitle;
            _usernameController.text = payload?.username ?? '';
            _emailController.text = payload?.email ?? '';
            _passwordController.text = payload?.password ?? '';
          });
        }
      } catch (e) {
        // If decryption fails, controllers are already initialized with empty text
        print('Decryption error: $e');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get master password from secure storage
      final session = await _authStorage.getUserSession();
      final masterPassword = session?['userId'] ?? userId; // TODO: Use actual master password

      // Generate secure salt/nonce (use same value for both key derivation and AES)
      final saltNonce = EncryptionService.generateNonce();

      // Derive encryption key using Argon2
      final encryptionKey = await EncryptionService.deriveKeyArgon2(
        masterPassword: masterPassword,
        salt: saltNonce,
      );

      // Create payload with all sensitive data
      final payload = VaultItemPayload(
        username: _usernameController.text.isEmpty
            ? null
            : _usernameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        password: _passwordController.text.isEmpty
            ? null
            : _passwordController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // Encrypt the entire payload using AES-256-GCM
      final encryptedPayload = EncryptionService.encryptPayload(
        payload: payload,
        encryptionKey: encryptionKey,
        nonce: saltNonce,
      );

      // Encrypt title separately (also sensitive)
      final titleBytes = utf8.encode(_titleController.text);
      final titleKey = encrypt.Key(encryptionKey);
      final titleIv = encrypt.IV(saltNonce);
      final titleEncrypter = encrypt.Encrypter(
        encrypt.AES(titleKey, mode: encrypt.AESMode.gcm),
      );
      final encryptedTitleData = titleEncrypter.encryptBytes(titleBytes, iv: titleIv);
      final encryptedTitle = encryptedTitleData.base64;

      final vaultItem = VaultItem(
        id: widget.existingItem?.id ?? const Uuid().v4(),
        userId: userId,
        title: encryptedTitle, // Now encrypted
        category: _selectedCategory,
        websiteUrl: _websiteController.text.isEmpty
            ? null
            : _websiteController.text, // Can stay unencrypted for icon fetching
        notesPreview: null, // Don't store preview in plain text
        encryptedPayload: encryptedPayload,
        nonce: base64Encode(saltNonce), // Store salt/nonce for both key derivation and AES
        isFavorite: _isFavorite,
        passwordHealth: _passwordController.text.isEmpty
            ? PasswordHealthStatus.unknown
            : _getPasswordHealth(_passwordController.text),
        iconUrl: _getBrandfetchLogoUrl(_websiteController.text),
        iconCachedAt: _websiteController.text.isEmpty ? null : DateTime.now(),
        createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        version: (widget.existingItem?.version ?? 0) + 1,
      );

      if (widget.existingItem != null) {
        await _supabaseService.updateVaultItem(vaultItem);
      } else {
        await _supabaseService.createVaultItem(vaultItem);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        toastification.show(
          context: context,
          title: Text(
            widget.existingItem != null
                ? 'Password updated successfully'
                : 'Password added successfully',
          ),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Error: $e'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  PasswordHealthStatus _getPasswordHealth(String password) {
    final strength = PasswordGeneratorService.calculatePasswordStrength(
      password,
    );
    if (strength >= 80) return PasswordHealthStatus.strong;
    if (strength >= 50) return PasswordHealthStatus.weak;
    return PasswordHealthStatus.weak;
  }

  void _generatePassword() {
    final generatedPassword = PasswordGeneratorService.generatePassword(
      length: 16,
      includeUppercase: true,
      includeLowercase: true,
      includeNumbers: true,
      includeSymbols: true,
    );
    setState(() {
      _passwordController.text = generatedPassword;
    });
    HapticFeedback.mediumImpact();
  }

  /// Sanitize URL to get domain for brandfetch
  String? _sanitizeUrlForBrandfetch(String? url) {
    if (url == null || url.isEmpty) return null;

    // Remove protocol
    String domain = url
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll(RegExp(r'^www\.'), '');

    // Remove path and query parameters
    final slashIndex = domain.indexOf('/');
    if (slashIndex != -1) {
      domain = domain.substring(0, slashIndex);
    }

    return domain.isNotEmpty ? domain : null;
  }

  /// Get brandfetch logo URL
  String? _getBrandfetchLogoUrl(String? websiteUrl) {
    final domain = _sanitizeUrlForBrandfetch(websiteUrl);
    if (domain == null) return null;
    final apiKey = dotenv.env['BRANDFETCH_API_KEY'] ?? '';
    return 'https://cdn.brandfetch.io/$domain?c=$apiKey';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle

        // Header
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.existingItem != null
                          ? 'Edit Password'
                          : 'Add Password',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.existingItem != null
                          ? 'Update password details'
                          : 'Save a new password securely',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill),
                onPressed: () => Navigator.of(context).pop(),
                iconSize: 28,
                color: theme.colorScheme.onSurface.withAlpha(50),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Form
        Flexible(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category selector
                  Text(
                    'Category',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(120),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withAlpha(50),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<CredentialCategory>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: CredentialCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(_getCategoryIcon(category), size: 20),
                              const SizedBox(width: 12),
                              Text(_getCategoryName(category)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  _buildTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'e.g., Google Account',
                    icon: CupertinoIcons.textbox,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Website URL with logo preview
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _websiteController,
                          label: 'Website URL',
                          hint: 'https://example.com',
                          icon: CupertinoIcons.globe,
                          keyboardType: TextInputType.url,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      if (_getBrandfetchLogoUrl(_websiteController.text) !=
                          null)
                        const SizedBox(width: 12),
                      if (_getBrandfetchLogoUrl(_websiteController.text) !=
                          null)
                        Container(
                          width: 56,
                          height: 56,
                          // margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _getBrandfetchLogoUrl(_websiteController.text)!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    CupertinoIcons.globe,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Username
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Enter username',
                    icon: CupertinoIcons.person,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'user@example.com',
                    icon: CupertinoIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Text(
                    'Password',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withAlpha(120),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Enter password',
                              filled: false,
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  50,
                                ),
                              ),
                              prefixIcon: Icon(
                                CupertinoIcons.lock,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  150,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? CupertinoIcons.eye_slash
                                      : CupertinoIcons.eye,
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    150,
                                  ),
                                ),
                                onPressed: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    50,
                                  ),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withAlpha(120),
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            CupertinoIcons.arrow_clockwise,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: _generatePassword,
                          tooltip: 'Generate password',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  _buildTextField(
                    controller: _notesController,
                    label: 'Notes',
                    hint: 'Add notes (optional)',
                    icon: CupertinoIcons.doc_text,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Favorite toggle
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withAlpha(120),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withAlpha(50),
                        width: 1.5,
                      ),
                    ),
                    child: SwitchListTile(
                      value: _isFavorite,
                      onChanged: (value) => setState(() => _isFavorite = value),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      title: Text(
                        'Add to favorites',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      secondary: Icon(
                        _isFavorite
                            ? CupertinoIcons.star_fill
                            : CupertinoIcons.star,
                        color: _isFavorite
                            ? Colors.amber
                            : theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        // Actions
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withAlpha(30),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withAlpha(80),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          widget.existingItem != null
                              ? 'Update Password'
                              : 'Add Password',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            onChanged: onChanged,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              filled: false,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(100),
              ),
              prefixIcon: Icon(
                icon,
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.onSurface.withAlpha(50),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
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

  String _getCategoryName(CredentialCategory category) {
    switch (category) {
      case CredentialCategory.login:
        return 'Login';
      case CredentialCategory.creditCard:
        return 'Credit Card';
      case CredentialCategory.identity:
        return 'Identity';
      case CredentialCategory.secureNote:
        return 'Secure Note';
      case CredentialCategory.apiKey:
        return 'API Key';
      case CredentialCategory.bankAccount:
        return 'Bank Account';
      case CredentialCategory.cryptoWallet:
        return 'Crypto Wallet';
      case CredentialCategory.sshKey:
        return 'SSH Key';
      case CredentialCategory.license:
        return 'License';
      case CredentialCategory.custom:
        return 'Custom';
    }
  }
}

// Helper function to show the dialog
Future<bool?> showVaultAddEditDialog(
  BuildContext context, {
  VaultItem? existingItem,
  CredentialCategory? initialCategory,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Theme.of(context).colorScheme.onSurface.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: VaultAddEditDialog(
                existingItem: existingItem,
                initialCategory: initialCategory,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
