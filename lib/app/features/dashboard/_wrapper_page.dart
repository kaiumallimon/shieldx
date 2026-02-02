import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'shared/widgets/app_drawer.dart';

final wrapperScaffoldKey = GlobalKey<ScaffoldState>();

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
      case '/manage':
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
        context.go('/manage');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _getSelectedIndex(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: theme.colorScheme.surface,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      key: wrapperScaffoldKey,
      drawer: const AppDrawer(),
      body: widget.child,
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: theme.colorScheme.surface,
        activeColor: theme.colorScheme.primary,
        inactiveColor: theme.colorScheme.onSurfaceVariant,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.lock_shield),
            label: 'Vault',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.shield),
            label: 'Security',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.lock_rotation),
            label: 'Generator',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.wrench),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            label: 'Manage',
          ),
        ],
      ),
    );
  }
}
