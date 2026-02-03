import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
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

    return BlocBuilder<ManageCubit, ManageState>(
      builder: (context, state) {
        if (state is ManageInitial) {
          context.read<ManageCubit>().loadData();
          return _buildShimmerLoading(context);
        }

        if (state is ManageLoading) {
          return _buildShimmerLoading(context);
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
                // Scrollable content with iOS-style pull-to-refresh
                CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // iOS-style refresh control
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        await context.read<ManageCubit>().loadData();
                      },
                    ),
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
                            icon: CupertinoIcons.lock_shield,
                            title: 'Login',
                            count: loaded.categoryCounts['login'] ?? 0,
                            color: theme.colorScheme.primary,
                            onTap: () {
                              context.push('/manage/category/login');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.creditcard,
                            title: 'Credit Card',
                            count: loaded.categoryCounts['credit_card'] ?? 0,
                            color: theme.colorScheme.secondary,
                            onTap: () {
                              context.push('/manage/category/credit_card');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.person_badge_plus,
                            title: 'Identity',
                            count: loaded.categoryCounts['identity'] ?? 0,
                            color: theme.colorScheme.tertiary,
                            onTap: () {
                              context.push('/manage/category/identity');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.doc_text,
                            title: 'Secure Note',
                            count: loaded.categoryCounts['secure_note'] ?? 0,
                            color: theme.colorScheme.error,
                            onTap: () {
                              context.push('/manage/category/secure_note');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.lock_rotation,
                            title: 'API Key',
                            count: loaded.categoryCounts['api_key'] ?? 0,
                            color: theme.colorScheme.primaryContainer,
                            onTap: () {
                              context.push('/manage/category/api_key');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.building_2_fill,
                            title: 'Bank Account',
                            count: loaded.categoryCounts['bank_account'] ?? 0,
                            color: theme.colorScheme.secondaryContainer,
                            onTap: () {
                              context.push('/manage/category/bank_account');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.money_dollar_circle,
                            title: 'Crypto Wallet',
                            count: loaded.categoryCounts['crypto_wallet'] ?? 0,
                            color: theme.colorScheme.tertiaryContainer,
                            onTap: () {
                              context.push('/manage/category/crypto_wallet');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.command,
                            title: 'SSH Key',
                            count: loaded.categoryCounts['ssh_key'] ?? 0,
                            color: theme.colorScheme.primary,
                            onTap: () {
                              context.push('/manage/category/ssh_key');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.doc_on_clipboard,
                            title: 'License',
                            count: loaded.categoryCounts['license'] ?? 0,
                            color: theme.colorScheme.secondary,
                            onTap: () {
                              context.push('/manage/category/license');
                            },
                          ),
                          _buildCategoryCard(
                            context,
                            icon: CupertinoIcons.square_favorites_alt,
                            title: 'Custom',
                            count: loaded.categoryCounts['custom'] ?? 0,
                            color: theme.colorScheme.tertiary,
                            onTap: () {
                              context.push('/manage/category/custom');
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

  Widget _buildShimmerLoading(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;
    final appBarHeight = windowSize.height * 0.067;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Container(color: theme.colorScheme.surface),
            CustomScrollView(
              controller: _scrollController,
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: appBarHeight + MediaQuery.of(context).padding.top,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildShimmerMainCard(theme),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerText(theme, width: 100, height: 20),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildShimmerCategoryCard(theme),
                      childCount: 10,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerMainCard(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.secondary.withAlpha(25),
      highlightColor: theme.colorScheme.secondary.withAlpha(50),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCategoryCard(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.secondary.withAlpha(25),
      highlightColor: theme.colorScheme.secondary.withAlpha(50),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 50,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerText(ThemeData theme,
      {required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.secondary.withAlpha(25),
      highlightColor: theme.colorScheme.secondary.withAlpha(100),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
