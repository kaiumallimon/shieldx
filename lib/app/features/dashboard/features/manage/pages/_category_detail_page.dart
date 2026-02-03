import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';
import 'package:shieldx/app/features/dashboard/features/vault/widgets/_vault_add_edit_dialog.dart';
import 'package:shieldx/app/features/dashboard/features/manage/widgets/_category_header_widget.dart';
import 'package:shieldx/app/features/dashboard/features/manage/widgets/_category_empty_state_widget.dart';
import 'package:shieldx/app/features/dashboard/features/manage/widgets/_category_password_card_widget.dart';
import 'package:shieldx/app/features/dashboard/features/manage/widgets/_category_shimmer_card_widget.dart';
import 'package:shieldx/app/features/dashboard/features/manage/utils/_category_helpers.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';

class CategoryDetailPage extends StatefulWidget {
  final String category;

  const CategoryDetailPage({super.key, required this.category});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final SupabaseVaultService _vaultService = SupabaseVaultService();
  bool _isLoading = true;
  List<VaultItem> _categoryPasswords = [];

  @override
  void initState() {
    super.initState();
    _loadCategoryPasswords();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryPasswords() async {
    setState(() => _isLoading = true);
    try {
      final allItems = await _vaultService.getAllVaultItems();
      final categoryEnum = CategoryHelpers.getCategoryEnum(widget.category);

      if (mounted) {
        setState(() {
          _categoryPasswords = allItems
              .where((item) => item.category == categoryEnum)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading passwords: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAddPasswordBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.95,
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
                    color: theme.colorScheme.onSurface.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Expanded dialog content
                Flexible(
                  child: VaultAddEditDialog(
                    initialCategory: CategoryHelpers.getCategoryEnum(widget.category),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((result) {
      if (result == true && mounted) {
        // Reload passwords
        _loadCategoryPasswords();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryName = CategoryHelpers.getCategoryDisplayName(widget.category);
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
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // iOS-style refresh control
                CupertinoSliverRefreshControl(
                  onRefresh: _loadCategoryPasswords,
                ),
                // Top spacing for appbar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: appBarHeight + MediaQuery.of(context).padding.top,
                  ),
                ),
                // Category header
                SliverToBoxAdapter(
                  child: CategoryHeaderWidget(
                    categoryName: categoryName,
                    categoryIcon: CategoryHelpers.getCategoryIcon(widget.category),
                    categoryColor: CategoryHelpers.getCategoryColor(context, widget.category),
                    itemCount: _categoryPasswords.length,
                  ),
                ),
                // Passwords list
                _isLoading
                    ? SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const CategoryShimmerCardWidget(),
                            childCount: 5,
                          ),
                        ),
                      )
                    : _categoryPasswords.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: CategoryEmptyStateWidget(),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = _categoryPasswords[index];
                                  return CategoryPasswordCardWidget(
                                    item: item,
                                    onUpdate: _loadCategoryPasswords,
                                  );
                                },
                                childCount: _categoryPasswords.length,
                              ),
                            ),
                          ),
                // Bottom spacing
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 76 + MediaQuery.of(context).padding.bottom + 32,
                  ),
                ),
              ],
            ),
            // Scrollable AppBar
            ScrollableAppBar(
              title: categoryName,
              scrollController: _scrollController,
              leading: CircularActionButton(
                scrollController: _scrollController,
                icon: LucideIcons.arrowLeft,
                onTap: () => Navigator.of(context).pop(),
              ),
              trailing: CircularActionButton(
                backgroundColor: theme.colorScheme.primary,
                iconColor: theme.colorScheme.onPrimary,
                scrollController: _scrollController,
                icon: CupertinoIcons.add,
                onTap: _showAddPasswordBottomSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
