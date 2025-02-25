import 'package:flutter/material.dart';
import 'package:shieldx/app/core/constants/_assets.dart';
import 'package:shieldx/app/core/constants/_strings.dart';
import 'package:shieldx/app/core/theme/_styles.dart';

import '../../../../core/utils/_system_bar_colors.dart';

class OnboardPage extends StatelessWidget {
  const OnboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // get theme
    final theme = Theme.of(context).colorScheme;

    // set status bar color and navigation bar color
    setUiColors(theme);

    // get screen size
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 15,
            children: [
              // onboard image
              Image.asset(AppAssets.onboarding1),

              // onboard title
              Text(
                AppStrings.onboardingTitle1,
                style: AppStyles.titleStyle.copyWith(color: theme.onSurface),
              ),

              // onboard description
              Text(AppStrings.onboardingSubTitle1),

              // button row
            ],
          ),
        ),
      ),
    );
  }
}
