import 'package:flutter/material.dart';

import '../../controller/_onboard_controller.dart';

Image buildOnboardImage(OnboardController controller, int index, Size size) {
    return Image.asset(
                      controller.getImage(index),
                      fit: BoxFit.contain,
                      height: size.height * 0.4,
                    );
  }