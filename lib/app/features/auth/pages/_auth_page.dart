import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shieldx/app/features/auth/widgets/_auth_header.dart';
import 'package:shieldx/app/features/auth/widgets/_auth_toggle.dart';

class AuthPage extends StatefulWidget {
  final int initialIndex;

  const AuthPage({
    super.key,
    this.initialIndex = 1, // 0 for Register, 1 for Login
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void changeMenuIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusBarSize = MediaQuery.of(context).padding.top;
    final navigationBarSize = MediaQuery.of(context).padding.bottom;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: theme.colorScheme.secondary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          AuthHeader(
            selectedIndex: selectedIndex,
            statusBarSize: statusBarSize,
            navigationBarSize: navigationBarSize,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface),
              child: Column(
                children: [
                  AuthToggle(
                    selectedIndex: selectedIndex,
                    onToggle: changeMenuIndex,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
