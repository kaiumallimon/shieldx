import 'package:flutter/material.dart';
import 'package:shieldx/app/core/widgets/_custom_loading.dart';

import '../constants/_sizes.dart';
import '../theme/_styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.height = AppSize.buttonHeight,
      this.width,
      this.isLoading = false,
      required this.color,
      required this.textColor});

  final String text;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final Color color;
  final Color textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSize.cardHorizontalPadding,
            vertical: AppSize.insidePadding),
        decoration: BoxDecoration(
            color: isLoading ? color.withOpacity(.7) : color,
            borderRadius: BorderRadius.circular(AppSize.borderRadius)),
        child: Center(
          child: isLoading
              ? CustomLoading(
                  color: textColor,
                  size: 18,
                )
              : Text(
                  text,
                  style: AppStyles.buttonTextStyle.copyWith(
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
