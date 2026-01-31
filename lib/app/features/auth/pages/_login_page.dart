import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shieldx/app/core/themes/_app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginTitle = 'Welcome Back!';
  final loginSubtitle = 'Please login to your account to continue.';
  final registrationTitle = 'Get Started now';
  final registrationSubtitle = 'Create an account to get started with ShieldX.';
  int selectedIndex = 1; // 0 for Register, 1 for Login

  void changeMenuIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;
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
          _topContainer(theme, statusBarSize, navigationBarSize),

          Expanded(
            child: Container(
              decoration: BoxDecoration(color: theme.colorScheme.surface),
              child: Column(
                children: [
                  // menu bar
                  Container(
                    height: 64,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.background,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            key: ValueKey('register_container'),
                            duration: const Duration(milliseconds: 300),
                            margin: selectedIndex == 0
                                ? EdgeInsets.all(6)
                                : EdgeInsets.zero,
                            child: Material(
                              color: selectedIndex == 0
                                  ? theme.colorScheme.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => changeMenuIndex(0),
                                borderRadius: BorderRadius.circular(8),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
                                  child: Text(
                                    'Register',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: selectedIndex == 0
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface.withOpacity(
                                              0.6,
                                            ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AnimatedContainer(
                            key: ValueKey('login_container'),
                            duration: const Duration(milliseconds: 300),
                            margin: selectedIndex == 1
                                ? EdgeInsets.all(6)
                                : EdgeInsets.zero,
                            child: Material(
                              color: selectedIndex == 1
                                  ? theme.colorScheme.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => changeMenuIndex(1),
                                borderRadius: BorderRadius.circular(8),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
                                  child: Text(
                                    'Login',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: selectedIndex == 1
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface.withOpacity(
                                              0.6,
                                            ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _topContainer(
    ThemeData theme,
    double statusBarSize,
    double navigationBarSize,
  ) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.secondary,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 25 + statusBarSize,
        bottom: 25 + navigationBarSize,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _appLogo(theme),
          const SizedBox(height: 15),
          _titleText(theme),
          const SizedBox(height: 10),
          _subtitleText(theme),
        ],
      ),
    );
  }

  Text _subtitleText(ThemeData theme) {
    return Text(
      selectedIndex == 0 ? registrationSubtitle : loginSubtitle,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSecondary.withOpacity(0.7),
      ),
    );
  }

  Text _titleText(ThemeData theme) {
    return Text(
      selectedIndex == 0 ? registrationTitle : loginTitle,
      style: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.onSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Row _appLogo(ThemeData theme) {
    return Row(
      spacing: 10,
      children: [
        Image.asset('assets/logo/2.png', height: 25),
        Text(
          'ShieldX',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
