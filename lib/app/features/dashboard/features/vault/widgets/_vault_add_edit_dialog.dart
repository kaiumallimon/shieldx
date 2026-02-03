import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/core/services/password_generator_service.dart';

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
    _selectedCategory = widget.initialCategory ?? widget.existingItem?.category ?? CredentialCategory.login;
    _isFavorite = widget.existingItem?.isFavorite ?? false;

    // Initialize controllers with existing data if editing
    _titleController = TextEditingController(text: widget.existingItem?.title);
    _websiteController = TextEditingController(text: widget.existingItem?.websiteUrl);
    _notesController = TextEditingController(text: widget.existingItem?.notesPreview);

    // TODO: Decrypt existing payload if editing
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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

      // Create encrypted payload (simplified for now - should use proper encryption)
      final payload = VaultItemPayload(
        username: _usernameController.text.isEmpty ? null : _usernameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      // TODO: Properly encrypt payload with user's master key
      final encryptedPayload = base64Encode(utf8.encode(jsonEncode(payload.toJson())));
      final nonce = base64Encode(utf8.encode(const Uuid().v4())); // Should be proper nonce

      final vaultItem = VaultItem(
        id: widget.existingItem?.id ?? const Uuid().v4(),
        userId: userId,
        title: _titleController.text,
        category: _selectedCategory,
        websiteUrl: _websiteController.text.isEmpty ? null : _websiteController.text,
        notesPreview: _notesController.text.isEmpty ? null : _notesController.text.substring(0, _notesController.text.length > 100 ? 100 : _notesController.text.length),
        encryptedPayload: encryptedPayload,
        nonce: nonce,
        isFavorite: _isFavorite,
        passwordHealth: _passwordController.text.isEmpty
            ? PasswordHealthStatus.unknown
            : _getPasswordHealth(_passwordController.text),
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
          title: Text(widget.existingItem != null ? 'Password updated successfully' : 'Password added successfully'),
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
    final strength = PasswordGeneratorService.calculatePasswordStrength(password);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.existingItem != null ? CupertinoIcons.pencil : CupertinoIcons.add,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.existingItem != null ? 'Edit Password' : 'Add Password',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(CupertinoIcons.xmark, color: theme.colorScheme.onPrimaryContainer),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
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
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<CredentialCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      validator: (value) => value?.isEmpty ?? true ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Website URL
                    _buildTextField(
                      controller: _websiteController,
                      label: 'Website URL',
                      hint: 'https://example.com',
                      icon: CupertinoIcons.globe,
                      keyboardType: TextInputType.url,
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
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Enter password',
                                prefixIcon: const Icon(CupertinoIcons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(CupertinoIcons.refresh, color: theme.colorScheme.onSecondaryContainer),
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
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        value: _isFavorite,
                        onChanged: (value) => setState(() => _isFavorite = value),
                        title: const Text('Add to favorites'),
                        secondary: Icon(
                          _isFavorite ? CupertinoIcons.star_fill : CupertinoIcons.star,
                          color: _isFavorite ? Colors.amber : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.existingItem != null ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
  return showDialog<bool>(
    context: context,
    builder: (context) => VaultAddEditDialog(
      existingItem: existingItem,
      initialCategory: initialCategory,
    ),
  );
}
