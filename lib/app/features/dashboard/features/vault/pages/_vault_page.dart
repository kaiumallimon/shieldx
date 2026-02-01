import 'package:flutter/material.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_button.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_category_bottom_sheet.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_avatar.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_slogan_section.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_password_health_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_categories_section.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_types_section.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  // Service for managing authentication and user session data
  final AuthStorageService _authStorage = AuthStorageService();

  // User profile information
  String? userName;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar with user avatar and add button
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverAppBar(
                backgroundColor: theme.colorScheme.surface,
                leading: Container(
                  padding: const EdgeInsets.all(2),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2.5,
                    ),
                  ),
                  child: VaultAvatar(userName: userName, avatarUrl: avatarUrl),
                ),
                pinned: true,
                actions: [
                  VaultAddButton(
                    onPressed: () {
                      // Navigate to add password page
                    },
                  ),
                ],
              ),
            ),
            // Welcome slogan section
            const SliverToBoxAdapter(child: VaultSloganSection()),
            // Horizontal scrollable categories with fade effect
            SliverToBoxAdapter(
              child: VaultCategoriesSection(
                categories: _categories,
                onAddCategory: () => showAddCategoryBottomSheet(context),
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
                  totalPasswords: 69,
                  safeCount: 54,
                  weakCount: 12,
                  reusedCount: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
