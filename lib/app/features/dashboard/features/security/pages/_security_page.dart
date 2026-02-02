import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/data/services/supabase_vault_service.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _vaultService = SupabaseVaultService();

  bool _isLoading = true;
  int _totalPasswords = 0;
  int _weakPasswords = 0;
  int _reusedPasswords = 0;
  int _breachedPasswords = 0;
  int _strongPasswords = 0;
  int _securityScore = 0;

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  Future<void> _loadSecurityData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final stats = await _vaultService.getPasswordHealthStats();
      final total = await _vaultService.getTotalItemsCount();

      setState(() {
        _totalPasswords = total;
        _strongPasswords = stats['strong'] ?? 0;
        _weakPasswords = stats['weak'] ?? 0;
        _reusedPasswords = stats['reused'] ?? 0;
        _breachedPasswords = stats['breached'] ?? 0;

        // Calculate security score
        if (_totalPasswords > 0) {
          final strongPercent = (_strongPasswords / _totalPasswords) * 100;
          final weakPercent = (_weakPasswords / _totalPasswords) * 100;
          final reusedPercent = (_reusedPasswords / _totalPasswords) * 100;
          final breachedPercent = (_breachedPasswords / _totalPasswords) * 100;

          _securityScore = (strongPercent -
                           (weakPercent * 0.5) -
                           (reusedPercent * 0.8) -
                           (breachedPercent * 1.5))
              .clamp(0, 100)
              .round();
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    final scoreColor = _getScoreColor(_securityScore);
    final scoreLabel = _getScoreLabel(_securityScore);

    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverAppBar(
                backgroundColor: CupertinoColors.systemGroupedBackground,
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
                    onPressed: _loadSecurityData,
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
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_securityScore',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 72,
                        ),
                      ),
                      Text(
                        scoreLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_totalPasswords passwords analyzed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
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
                        icon: CupertinoIcons.checkmark_shield,
                        label: 'Strong',
                        count: _strongPasswords,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: CupertinoIcons.exclamationmark_triangle,
                        label: 'Weak',
                        count: _weakPasswords,
                        color: Colors.orange,
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
                        icon: CupertinoIcons.arrow_2_squarepath,
                        label: 'Reused',
                        count: _reusedPasswords,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: CupertinoIcons.xmark_shield,
                        label: 'Breached',
                        count: _breachedPasswords,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // Security alerts
            if (_weakPasswords > 0 || _reusedPasswords > 0 || _breachedPasswords > 0) ...[
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (_weakPasswords > 0) ...[
                          _buildAlertTile(
                            context,
                            icon: CupertinoIcons.exclamationmark_triangle_fill,
                            title: 'Weak Passwords',
                            subtitle: '$_weakPasswords passwords need strengthening',
                            color: Colors.orange,
                            onTap: () {},
                          ),
                          if (_reusedPasswords > 0 || _breachedPasswords > 0)
                            _buildDivider(),
                        ],
                        if (_reusedPasswords > 0) ...[
                          _buildAlertTile(
                            context,
                            icon: CupertinoIcons.arrow_2_squarepath,
                            title: 'Reused Passwords',
                            subtitle: '$_reusedPasswords passwords are reused',
                            color: Colors.red,
                            onTap: () {},
                          ),
                          if (_breachedPasswords > 0) _buildDivider(),
                        ],
                        if (_breachedPasswords > 0)
                          _buildAlertTile(
                            context,
                            icon: CupertinoIcons.xmark_shield_fill,
                            title: 'Breached Passwords',
                            subtitle: '$_breachedPasswords passwords compromised',
                            color: Colors.purple,
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
                    icon: CupertinoIcons.arrow_clockwise_circle,
                    title: 'Update All Weak',
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  _buildActionCard(
                    context,
                    icon: CupertinoIcons.search_circle,
                    title: 'Check Breaches',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _buildActionCard(
                    context,
                    icon: CupertinoIcons.chart_bar_circle,
                    title: 'View Report',
                    color: Colors.green,
                    onTap: () {},
                  ),
                  _buildActionCard(
                    context,
                    icon: CupertinoIcons.arrow_down_circle,
                    title: 'Export Data',
                    color: Colors.purple,
                    onTap: () {},
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

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
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
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Weak';
    return 'Critical';
  }
}