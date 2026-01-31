import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final int selectedIndex;
  final double statusBarSize;
  final double navigationBarSize;

  const AuthHeader({
    super.key,
    required this.selectedIndex,
    required this.statusBarSize,
    required this.navigationBarSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loginTitle = 'Welcome Back!';
    final loginSubtitle = 'Please login to your account to continue.';
    final registrationTitle = 'Get Started now';
    final registrationSubtitle = 'Create an account to get started with ShieldX.';

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
          _buildAppLogo(theme),
          const SizedBox(height: 15),
          _buildTitle(theme, selectedIndex == 0 ? registrationTitle : loginTitle),
          const SizedBox(height: 10),
          _buildSubtitle(
            theme,
            selectedIndex == 0 ? registrationSubtitle : loginSubtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo(ThemeData theme) {
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

  Widget _buildTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.onSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme, String subtitle) {
    return Text(
      subtitle,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSecondary.withOpacity(0.7),
      ),
    );
  }
}
