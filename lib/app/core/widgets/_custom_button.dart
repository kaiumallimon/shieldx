import 'package:flutter/material.dart';

import '../constants/_sizes.dart';
import '../theme/_styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.height = AppSize.buttonHeight,
      this.width,
      required this.color,
      required this.textColor});

  final String text;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSize.cardHorizontalPadding,
            vertical: AppSize.insidePadding),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSize.borderRadius)),
        child: Center(
          child: Text(
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