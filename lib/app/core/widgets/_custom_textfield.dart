import 'package:flutter/material.dart';
import 'package:shieldx/app/core/constants/_sizes.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool? obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool? readOnly;
  final bool? enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool? autoFocus;
  final bool? autoCorrect;
  final List<String>? autoFillHints;
  final bool? showCursor;
  final Color fillColor;
  final Color textColor;
  final Color? hintColor;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.validator,
    this.controller,
    this.readOnly,
    this.enabled,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.autoFocus,
    this.autoCorrect,
    this.autoFillHints,
    this.showCursor,
    required this.fillColor,
    required this.textColor,
    required this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: AppSize.inputHeight,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Row(
          spacing: 10,
          children: [
            if (prefixIcon != null) prefixIcon!,
            Expanded(
              child: TextFormField(
                controller: controller,
                readOnly: readOnly ?? false,
                enabled: enabled ?? true,
                maxLines: maxLines ?? 1,
                minLines: minLines ?? 1,
                maxLength: maxLength,
                autofocus: autoFocus ?? false,
                autocorrect: autoCorrect ?? true,
                autofillHints: autoFillHints,
                showCursor: showCursor ?? true,
                keyboardType: keyboardType ?? TextInputType.text,
                textInputAction: textInputAction ?? TextInputAction.next,
                obscureText: obscureText ?? false,
                onChanged: onChanged,
                onFieldSubmitted: onFieldSubmitted,
                onTap: onTap,
                validator: validator,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle:
                      TextStyle(color: hintColor, fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  errorStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
            ),
            if (suffixIcon != null) suffixIcon!,
          ],
        ),
      ),
    );
  }
}
