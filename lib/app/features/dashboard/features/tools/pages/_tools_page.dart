import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/shared/widgets/circular_action_button.dart';
import 'package:shieldx/app/shared/widgets/scrollable_appbar.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            slivers: [
              // Spacer for app bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 60,
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
                      theme,
                      icon: CupertinoIcons.checkmark_shield,
                      title: 'Password Strength Checker',
                      description: 'Analyze password security',
                      onTap: () {},
                    ),
                    _buildToolCard(
                      context,
                      theme,
                      icon: CupertinoIcons.exclamationmark_triangle,
                      title: 'Data Breach Detector',
                      description: 'Check if data was compromised',
                      onTap: () {},
                    ),
                    _buildToolCard(
                      context,
                      theme,
                      icon: CupertinoIcons.shield,
                      title: 'Security Audit',
                      description: 'Complete security scan',
                      onTap: () {},
                    ),
                    _buildToolCard(
                      context,
                      theme,
                      icon: CupertinoIcons.lock_rotation,
                      title: 'Passphrase Generator',
                      description: 'Create memorable phrases',
                      onTap: () {},
                    ),
                    _buildToolCard(
                      context,
                      theme,
                      icon: CupertinoIcons.clock,
                      title: 'Password Expiry',
                      description: 'Manage password age',
                      onTap: () {},
                    ),
                    _buildToolCard(
                      context,
                      theme,
                      icon: CupertinoIcons.arrow_2_squarepath,
                      title: 'Duplicate Finder',
                      description: 'Find reused passwords',
                      onTap: () {},
                    ),
                    _buildToolCard(
                      context,
                      theme,
                      icon: CupertinoIcons.arrow_down_doc,
                      title: 'Export Data',
                      description: 'Backup your vault',
                      onTap: () {},
                    ),
                    _buildToolCard(
                      context,
                      theme,
                      icon: CupertinoIcons.arrow_up_doc,
                      title: 'Import Data',
                      description: 'Restore from backup',
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
          // ScrollableAppBar
          ScrollableAppBar(
            scrollController: _scrollController,
            leading: CircularActionButton(
              icon: LucideIcons.menu,
              scrollController: _scrollController,
              onTap: () {
                wrapperScaffoldKey.currentState?.openDrawer();
              },
            ),
            title: 'Security Tools',
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: theme.colorScheme.onSurface),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(200),
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
