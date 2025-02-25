import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shieldx/app/core/constants/_assets.dart';
import 'package:shieldx/app/core/utils/_system_bar_colors.dart';
import 'package:shieldx/app/core/widgets/_custom_loading.dart';

import '../../controller/_splash_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // get theme
    final theme = Theme.of(context).colorScheme;

    // set status bar color and navigation bar color
    setUiColors(theme);

    // call goToLogin
    Get.find<SplashController>().goToLogin();

    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: Image.asset(AppAssets.logosmall),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: CustomLoading(color: theme.primary),
          )
        ],
      )),
    );
  }
}
