import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverAppBar(
                backgroundColor: theme.colorScheme.surface,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    wrapperScaffoldKey.currentState?.openDrawer();
                  },
                ),
                title: Text(
                  'Manage Vault',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                pinned: true,
              ),
            ),
            // All passwords card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildMainCard(
                  context,
                  icon: Icons.lock_outlined,
                  title: 'All Passwords',
                  subtitle: 'View and manage all your passwords',
                  color: theme.colorScheme.primary,
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    count: 12,
                    color: Colors.blue,
                    onTap: () {
                      context.push('/manage/category/work');
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    icon: Icons.person_outline,
                    title: 'Personal',
                    count: 25,
                    color: Colors.green,
                    onTap: () {
                      context.push('/manage/category/personal');
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    icon: Icons.public,
                    title: 'Social',
                    count: 8,
                    color: Colors.purple,
                    onTap: () {
                      context.push('/manage/category/social');
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    icon: Icons.account_balance,
                    title: 'Finance',
                    count: 6,
                    color: Colors.orange,
                    onTap: () {
                      context.push('/manage/category/finance');
                    },
                  ),
                  _buildCategoryCard(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shopping',
                    count: 10,
                    color: Colors.red,
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
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
                    count: 45,
                    onTap: () {
                      context.push('/manage/type/login');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTypeCard(
                    context,
                    icon: Icons.key,
                    title: 'API Keys',
                    count: 8,
                    onTap: () {
                      context.push('/manage/type/api-key');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTypeCard(
                    context,
                    icon: Icons.credit_card,
                    title: 'Credit Cards',
                    count: 3,
                    onTap: () {
                      context.push('/manage/type/credit-card');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTypeCard(
                    context,
                    icon: Icons.note,
                    title: 'Secure Notes',
                    count: 12,
                    onTap: () {
                      context.push('/manage/type/note');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTypeCard(
                    context,
                    icon: Icons.badge,
                    title: 'Identity Documents',
                    count: 5,
                    onTap: () {
                      context.push('/manage/type/identity');
                    },
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 32,
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
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
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
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
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
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
