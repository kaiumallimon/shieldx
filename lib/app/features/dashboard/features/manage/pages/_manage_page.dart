import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/features/dashboard/features/manage/cubit/_manage_cubit.dart';
import 'package:shieldx/app/features/dashboard/features/manage/cubit/_manage_state.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;
    final appBarHeight = windowSize.height * 0.067;

    return BlocBuilder<ManageCubit, ManageState>(
      builder: (context, state) {
        if (state is ManageInitial) {
          context.read<ManageCubit>().loadData();
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ManageLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ManageError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ManageCubit>().loadData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final loaded = state as ManageLoaded;

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
                // Scrollable content with top padding
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Top spacing for appbar
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height:
                            appBarHeight +
                            MediaQuery.of(context).padding.top +
                            0,
                      ),
                    ),
                    // All passwords card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildMainCard(
                          context,
                          icon: LucideIcons.key,
                          title: 'All Passwords',
                          subtitle:
                              '${loaded.totalPasswords} passwords in your vault',
                          onTap: () {
                            context.push('/manage/all-passwords');
                          },
                        ),
                      ),
                    ),
                    // Categories section
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Categories',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                    // Categories grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.3,
                            ),
                        delegate: SliverChildListDelegate([
                          _buildCategoryCard(
                            context,
                            icon: Icons.work_outline,
                            title: 'Work',
                            count: loaded.categoryCounts['work'] ?? 0,
                            color: theme.colorScheme.primary,
                            onTap: () {
                              context.push('/manage/category/work');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: Icons.person_outline,
                            title: 'Personal',
                            count: loaded.categoryCounts['personal'] ?? 0,
                            color: theme.colorScheme.secondary,
                            onTap: () {
                              context.push('/manage/category/personal');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: Icons.public,
                            title: 'Social',
                            count: loaded.categoryCounts['social'] ?? 0,
                            color: theme.colorScheme.tertiary,
                            onTap: () {
                              context.push('/manage/category/social');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: Icons.account_balance,
                            title: 'Finance',
                            count: loaded.categoryCounts['finance'] ?? 0,
                            color: theme.colorScheme.error,
                            onTap: () {
                              context.push('/manage/category/finance');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: Icons.shopping_bag_outlined,
                            title: 'Shopping',
                            count: loaded.categoryCounts['shopping'] ?? 0,
                            color: theme.colorScheme.primaryContainer,
                            onTap: () {
                              context.push('/manage/category/shopping');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: Icons.add,
                            title: 'Add Category',
                            count: null,
                            color: theme.colorScheme.secondary,
                            onTap: () {
                              // Show add category dialog
                            },
                          ),
                        ]),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                    // Types section
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password Types',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                    // Types list
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildTypeCard(
                            context,
                            icon: Icons.login,
                            title: 'Login Credentials',
                            count: loaded.typeCounts['login'] ?? 0,
                            onTap: () {
                              context.push('/manage/type/login');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTypeCard(
                            context,
                            icon: Icons.key,
                            title: 'API Keys',
                            count: loaded.typeCounts['api-key'] ?? 0,
                            onTap: () {
                              context.push('/manage/type/api-key');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTypeCard(
                            context,
                            icon: Icons.credit_card,
                            title: 'Credit Cards',
                            count: loaded.typeCounts['credit-card'] ?? 0,
                            onTap: () {
                              context.push('/manage/type/credit-card');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTypeCard(
                            context,
                            icon: Icons.note,
                            title: 'Secure Notes',
                            count: loaded.typeCounts['note'] ?? 0,
                            onTap: () {
                              context.push('/manage/type/note');
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTypeCard(
                            context,
                            icon: Icons.badge,
                            title: 'Identity Documents',
                            count: loaded.typeCounts['identity'] ?? 0,
                            onTap: () {
                              context.push('/manage/type/identity');
                            },
                          ),
                        ]),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    // Bottom spacing for floating navigation bar
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 76 + MediaQuery.of(context).padding.bottom + 32,
                      ),
                    ),
                  ],
                ),
                // AppBar with gradient
                ScrollableAppBar(
                  title: 'Manage Vault',
                  scrollController: _scrollController,
                  leading: CircularActionButton(
                    scrollController: _scrollController,
                    icon: LucideIcons.menu,
                    onTap: () {
                      wrapperScaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  trailing: CircularActionButton(
                    scrollController: _scrollController,
                    icon: CupertinoIcons.refresh,
                    onTap: () => context.read<ManageCubit>().loadData(),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 25, color: theme.colorScheme.onSecondary),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: theme.colorScheme.onSurface.withAlpha(50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int? count,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.secondary),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (count != null) ...[
              const SizedBox(height: 4),
              Text(
                '$count items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.onSecondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: theme.colorScheme.onSurface.withAlpha(50),
            ),
          ],
        ),
      ),
    );
  }
}
