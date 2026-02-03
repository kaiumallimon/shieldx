import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/features/dashboard/features/security/cubit/_security_cubit.dart';
import 'package:shieldx/app/features/dashboard/features/security/cubit/_security_state.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        if (state is SecurityInitial) {
          context.read<SecurityCubit>().loadSecurityData();
          return const Scaffold(
            body: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (state is SecurityLoading) {
          return const Scaffold(
            body: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (state is SecurityError) {
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
                    onPressed: () => context.read<SecurityCubit>().loadSecurityData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final loaded = state as SecurityLoaded;
        final scoreColor = _getScoreColor(loaded.securityScore, theme);
        final scoreLabel = _getScoreLabel(loaded.securityScore);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
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
                  'Security Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.refresh),
                    onPressed: () => context.read<SecurityCubit>().loadSecurityData(),
                  ),
                ],
                pinned: true,
              ),
            ),
            // Overall security score
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scoreColor,
                        scoreColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: scoreColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Security Score',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${loaded.securityScore}',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 72,
                        ),
                      ),
                      Text(
                        scoreLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${loaded.totalPasswords} passwords analyzed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Statistics cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        theme,
                        icon: CupertinoIcons.checkmark_shield,
                        label: 'Strong',
                        count: loaded.strongPasswords,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        theme,
                        icon: CupertinoIcons.exclamationmark_triangle,
                        label: 'Weak',
                        count: loaded.weakPasswords,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        theme,
                        icon: CupertinoIcons.arrow_2_squarepath,
                        label: 'Reused',
                        count: loaded.reusedPasswords,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        theme,
                        icon: CupertinoIcons.xmark_shield,
                        label: 'Breached',
                        count: loaded.breachedPasswords,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // Security alerts
            if (loaded.weakPasswords > 0 || loaded.reusedPasswords > 0 || loaded.breachedPasswords > 0) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Security Alerts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (loaded.weakPasswords > 0) ...[
                          _buildAlertTile(
                            context,
                            theme,
                            icon: CupertinoIcons.exclamationmark_triangle_fill,
                            title: 'Weak Passwords',
                            subtitle: '${loaded.weakPasswords} passwords need strengthening',
                            onTap: () {},
                          ),
                          if (loaded.reusedPasswords > 0 || loaded.breachedPasswords > 0)
                            _buildDivider(),
                        ],
                        if (loaded.reusedPasswords > 0) ...[
                          _buildAlertTile(
                            context,
                            theme,
                            icon: CupertinoIcons.arrow_2_squarepath,
                            title: 'Reused Passwords',
                            subtitle: '${loaded.reusedPasswords} passwords are reused',
                            onTap: () {},
                          ),
                          if (loaded.breachedPasswords > 0) _buildDivider(),
                        ],
                        if (loaded.breachedPasswords > 0)
                          _buildAlertTile(
                            context,
                            theme,
                            icon: CupertinoIcons.xmark_shield_fill,
                            title: 'Breached Passwords',
                            subtitle: '${loaded.breachedPasswords} passwords compromised',
                            onTap: () {},
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
            // Quick actions
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildListDelegate([
                  _buildActionCard(
                    context,
                    theme,
                    icon: CupertinoIcons.arrow_clockwise_circle,
                    title: 'Update All Weak',
                    onTap: () {},
                  ),
                  _buildActionCard(
                    context,
                    theme,
                    icon: CupertinoIcons.search_circle,
                    title: 'Check Breaches',
                    onTap: () {},
                  ),
                  _buildActionCard(
                    context,
                    theme,
                    icon: CupertinoIcons.chart_bar_circle,
                    title: 'View Report',
                    onTap: () {},
                  ),
                  _buildActionCard(
                    context,
                    theme,
                    icon: CupertinoIcons.arrow_down_circle,
                    title: 'Export Data',
                    onTap: () {},
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
      ),
    );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required int count,
  }) {
    final Color color = _getStatColor(label, theme);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final Color color = _getAlertColor(title, theme);
    return CupertinoListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 20),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final Color color = _getActionColor(title, theme);
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
      ),
    );
  }

  Color _getScoreColor(int score, ThemeData theme) {
    if (score >= 80) return theme.colorScheme.primary;
    if (score >= 60) return theme.colorScheme.secondary;
    if (score >= 40) return theme.colorScheme.tertiary;
    if (score >= 20) return theme.colorScheme.error;
    return theme.colorScheme.error;
  }

  Color _getStatColor(String label, ThemeData theme) {
    switch (label) {
      case 'Strong':
        return theme.colorScheme.primary;
      case 'Weak':
        return theme.colorScheme.tertiary;
      case 'Reused':
        return theme.colorScheme.error;
      case 'Breached':
        return theme.colorScheme.errorContainer;
      default:
        return theme.colorScheme.primary;
    }
  }

  Color _getAlertColor(String title, ThemeData theme) {
    if (title.contains('Weak')) return theme.colorScheme.tertiary;
    if (title.contains('Reused')) return theme.colorScheme.error;
    if (title.contains('Breached')) return theme.colorScheme.errorContainer;
    return theme.colorScheme.primary;
  }

  Color _getActionColor(String title, ThemeData theme) {
    if (title.contains('Update')) return theme.colorScheme.tertiary;
    if (title.contains('Check')) return theme.colorScheme.primary;
    if (title.contains('View')) return theme.colorScheme.secondary;
    if (title.contains('Export')) return theme.colorScheme.primaryContainer;
    return theme.colorScheme.primary;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Weak';
    return 'Critical';
  }
}