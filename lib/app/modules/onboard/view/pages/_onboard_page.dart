import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shieldx/app/core/constants/_sizes.dart';
import '../../../../core/utils/_system_bar_colors.dart';
import '../../controller/_onboard_controller.dart';
import '../parts/_onboard_button.dart';
import '../parts/_onboard_image.dart';
import '../parts/_onboard_indicator.dart';
import '../parts/_onboard_texts.dart';

class OnboardPage extends StatelessWidget {
  const OnboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final controller = Get.find<OnboardController>();

    setUiColors(theme);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.changePage,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.sidePadding,
                    vertical: AppSize.topBottomPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // image
                      buildOnboardImage(controller, index, size),
                      const SizedBox(height: 20),

                      // title and subtitle
                      buildOnboardTexts(controller, index, theme),
                      const SizedBox(height: 30),

                      // indicator
                      buildOnboardIndicator(controller, theme),
                      const SizedBox(height: 30),

                      // controlling button
                      buildOnboardButton(controller, theme, size),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
