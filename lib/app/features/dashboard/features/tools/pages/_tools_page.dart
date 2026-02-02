import 'package:flutter/material.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

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
                  'Security Tools',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                pinned: true,
              ),
            ),
            // Tools grid
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _buildToolCard(
                    context,
                    icon: Icons.verified_user,
                    title: 'Password Strength Checker',
                    description: 'Analyze password security',
                    gradient: [Colors.blue, Colors.blueAccent],
                    onTap: () {},
                  ),
                  _buildToolCard(
                    context,
                    icon: Icons.search,
                    title: 'Data Breach Detector',
                    description: 'Check if data was compromised',
                    gradient: [Colors.red, Colors.redAccent],
                    onTap: () {},
                  ),
                  _buildToolCard(
                    context,
                    icon: Icons.security,
                    title: 'Security Audit',
                    description: 'Complete security scan',
                    gradient: [Colors.green, Colors.greenAccent],
                    onTap: () {},
                  ),
                  _buildToolCard(
                    context,
                    icon: Icons.vpn_key,
                    title: 'Passphrase Generator',
                    description: 'Create memorable phrases',
                    gradient: [Colors.purple, Colors.purpleAccent],
                    onTap: () {},
                  ),
                  _buildToolCard(
                    context,
                    icon: Icons.lock_clock,
                    title: 'Password Expiry',
                    description: 'Manage password age',
                    gradient: [Colors.orange, Colors.orangeAccent],
                    onTap: () {},
                  ),
                  _buildToolCard(
                    context,
                    icon: Icons.compare_arrows,
                    title: 'Duplicate Finder',
                    description: 'Find reused passwords',
                    gradient: [Colors.teal, Colors.tealAccent],
                    onTap: () {},
                  ),
                  _buildToolCard(
                    context,
                    icon: Icons.file_download,
                    title: 'Export Data',
                    description: 'Backup your vault',
                    gradient: [Colors.indigo, Colors.indigoAccent],
                    onTap: () {},
                  ),
                  _buildToolCard(
                    context,
                    icon: Icons.file_upload,
                    title: 'Import Data',
                    description: 'Restore from backup',
                    gradient: [Colors.pink, Colors.pinkAccent],
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

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient[0],
              gradient[1],
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}