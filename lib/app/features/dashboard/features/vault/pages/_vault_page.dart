import 'package:flutter/material.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_button.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_avatar.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_slogan_section.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_password_health_card.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_categories_section.dart';

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
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                onAddCategory: () {
                  // add category tap
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: wrapperScaffoldKey.currentContext!,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.9,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
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
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    50,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // Scrollable content
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add New Category',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Create a custom category to organize your passwords',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withAlpha(180),
                                            ),
                                      ),
                                      const SizedBox(height: 24),
                                      TextField(
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          labelText: 'Category Name',
                                          hintText:
                                              'e.g., Banking, Entertainment',
                                          prefixIcon: Icon(
                                            Icons.label_outline,
                                            color: theme.colorScheme.primary,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: theme.colorScheme.primary,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Handle adding new category
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text('Add Category'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                onCategoryTap: (category) {
                  // category tap
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
