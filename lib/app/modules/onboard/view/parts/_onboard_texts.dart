import 'package:flutter/material.dart';

import '../../../../core/constants/_sizes.dart';
import '../../../../core/theme/_styles.dart';
import '../../controller/_onboard_controller.dart';

Padding buildOnboardTexts(
    OnboardController controller, int index, ColorScheme theme) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSize.insidePadding,
    ),
    child: Column(
      spacing: 15,
      children: [
        Text(
          controller.getTitle(index),
          textAlign: TextAlign.center,
          style: AppStyles.titleStyle.copyWith(
            color: theme.onSurface,
          ),
        ),
        Text(
          controller.getSubtitle(index),
          textAlign: TextAlign.center,
          style: AppStyles.subtitleStyle.copyWith(
            color: theme.onSurface.withOpacity(0.5),
            fontSize: AppSize.fontSmall,
          ),
        ),
      ],
    ),
  );
}
