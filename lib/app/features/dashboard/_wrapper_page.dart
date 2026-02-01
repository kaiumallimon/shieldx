import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shieldx/app/features/auth/cubit/_login_cubit.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key, required this.child});
  final Widget child;

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/home':
        return 0;
      case '/security':
        return 1;
      case '/generator':
        return 2;
      case '/tools':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/security');
        break;
      case 2:
        context.go('/generator');
        break;
      case 3:
        context.go('/tools');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(selectedIndex)),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<LoginCubit>().logout();
              if (context.mounted) {
                context.go('/auth');
              }
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.onSurface.withAlpha(20),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: theme.colorScheme.primary,
          shadowColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Vault',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield),
              label: 'Security',
            ),
            NavigationDestination(
              icon: Icon(Icons.vpn_key_outlined),
              selectedIcon: Icon(Icons.vpn_key),
              label: 'Generator',
            ),
            NavigationDestination(
              icon: Icon(Icons.build_outlined),
              selectedIcon: Icon(Icons.build),
              label: 'Tools',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Password Vault';
      case 1:
        return 'Security Check';
      case 2:
        return 'Password Generator';
      case 3:
        return 'Tools';
      case 4:
        return 'Settings';
      default:
        return 'ShieldX';
    }
  }
}
