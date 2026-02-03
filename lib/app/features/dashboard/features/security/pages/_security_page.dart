import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/features/dashboard/features/security/cubit/_security_cubit.dart';
import 'package:shieldx/app/features/dashboard/features/security/cubit/_security_state.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
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

    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        if (state is SecurityInitial) {
          context.read<SecurityCubit>().loadSecurityData();
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
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  slivers: [
                    // Pull to refresh
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        context.read<SecurityCubit>().loadSecurityData();
                        await Future.delayed(const Duration(seconds: 1));
                      },
                    ),
                    // Top spacing for appbar
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: appBarHeight + MediaQuery.of(context).padding.top,
                      ),
                    ),
                    // Content
                    if (state is SecurityLoading)
                      _buildLoadingState(theme)
                    else if (state is SecurityError)
                      _buildErrorState(context, theme, state.message)
                    else if (state is SecurityLoaded)
                      ..._buildLoadedState(context, theme, state),
                    // Bottom spacing
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 76 + MediaQuery.of(context).padding.bottom + 32,
                      ),
                    ),
                  ],
                ),
                // ScrollableAppBar
                ScrollableAppBar(
                  scrollController: _scrollController,
                  leading: CircularActionButton(
                    scrollController: _scrollController,
                    icon: LucideIcons.menu,
                    onTap: () {
                      wrapperScaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  title: 'Security Dashboard',
                  trailing: CircularActionButton(
                    icon: CupertinoIcons.refresh,
                    scrollController: _scrollController,
                    onTap: () =>
                        context.read<SecurityCubit>().loadSecurityData(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildShimmerCard(theme),
          childCount: 5,
        ),
      ),
    );
  }

  Widget _buildShimmerCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.secondary.withAlpha(25),
        highlightColor: theme.colorScheme.secondary.withAlpha(100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, String message) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading security data',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.read<SecurityCubit>().loadSecurityData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoadedState(BuildContext context, ThemeData theme, SecurityLoaded state) {
    final scoreColor = _getScoreColor(state.securityScore, theme);
    final scoreLabel = _getScoreLabel(state.securityScore);

    return [
      // Overall security score
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scoreColor, scoreColor.withOpacity(0.7)],
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
                  '${state.securityScore}',
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
                  '${state.totalPasswords} passwords analyzed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Statistics section header
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            'Password Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      // Statistics cards
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          delegate: SliverChildListDelegate([
            _buildStatCard(
              context,
              theme,
              icon: CupertinoIcons.checkmark_shield,
              label: 'Strong',
              count: state.strongPasswords,
            ),
            _buildStatCard(
              context,
              theme,
              icon: CupertinoIcons.exclamationmark_triangle,
              label: 'Weak',
              count: state.weakPasswords,
            ),
            _buildStatCard(
              context,
              theme,
              icon: CupertinoIcons.arrow_2_squarepath,
              label: 'Reused',
              count: state.reusedPasswords,
            ),
            _buildStatCard(
              context,
              theme,
              icon: CupertinoIcons.xmark_shield,
              label: 'Breached',
              count: state.breachedPasswords,
            ),
          ]),
        ),
      ),
      // Security alerts section
      if (state.weakPasswords > 0 ||
          state.reusedPasswords > 0 ||
          state.breachedPasswords > 0) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'Security Alerts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (state.weakPasswords > 0)
                _buildAlertCard(
                  context,
                  theme,
                  icon: CupertinoIcons.exclamationmark_triangle_fill,
                  title: 'Weak Passwords',
                  subtitle: '${state.weakPasswords} passwords need strengthening',
                  onTap: () {},
                ),
              if (state.reusedPasswords > 0)
                _buildAlertCard(
                  context,
                  theme,
                  icon: CupertinoIcons.arrow_2_squarepath,
                  title: 'Reused Passwords',
                  subtitle: '${state.reusedPasswords} passwords are reused',
                  onTap: () {},
                ),
              if (state.breachedPasswords > 0)
                _buildAlertCard(
                  context,
                  theme,
                  icon: CupertinoIcons.xmark_shield_fill,
                  title: 'Breached Passwords',
                  subtitle: '${state.breachedPasswords} passwords compromised',
                  onTap: () {},
                ),
            ]),
          ),
        ),
      ],
      // Quick actions section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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
    ];
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

  Widget _buildAlertCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final Color color = _getAlertColor(title, theme);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          CupertinoIcons.chevron_right,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
