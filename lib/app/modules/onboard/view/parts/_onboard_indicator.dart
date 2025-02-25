import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/_onboard_controller.dart';

Row buildOnboardIndicator(OnboardController controller, ColorScheme theme) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      3,
      (dotIndex) => Obx(() {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 10,
          width: controller.currentPage.value == dotIndex ? 30 : 10,
          decoration: BoxDecoration(
              color: controller.currentPage.value == dotIndex
                  ? theme.primary
                  : theme.onSurface.withOpacity(.3),
              // shape: BoxShape.circle,
              borderRadius: BorderRadius.circular(500)),
        );
      }),
    ),
  );
}
