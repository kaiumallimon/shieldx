import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'shared/widgets/app_drawer.dart';
import '../../shared/widgets/floating_bottom_nav.dart';

final wrapperScaffoldKey = GlobalKey<ScaffoldState>();

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key, required this.child});
  final Widget child;

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/home':
        return 0;
      case '/security':
        return 3;
      case '/generator':
        return 2;
      case '/tools':
        return 4;
      case '/manage':
        return 1;
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
        context.go('/manage');
        break;
      case 2:
        context.go('/generator');
        break;
      case 3:
        context.go('/security');
        break;
      case 4:
        context.go('/tools');
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
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    return Scaffold(
      key: wrapperScaffoldKey,
      drawer: const AppDrawer(),
      extendBody: true,
      body: Stack(
        children: [
          // Main content
          widget.child,
          // Floating bottom navigation
          FloatingBottomNav(
            selectedIndex: selectedIndex,
            onItemTapped: _onItemTapped,
            scrollController: _scrollController,
          ),
        ],
      ),
    );
  }
}
