import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/_strings.dart';
import '../../../../core/widgets/_custom_button.dart';
import '../../controller/_onboard_controller.dart';

Row buildOnboardButton(
    OnboardController controller, ColorScheme theme, Size size) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Obx(() {
        return CustomButton(
          text: controller.currentPage.value < 2
              ? AppStrings.next
              : AppStrings.getStarted,
          onPressed: () async {
            await controller.nextPage();
          },
          color: theme.primary,
          textColor: theme.onPrimary,
          width: size.width * 0.5,
        );
      }),
    ],
  );
}
