import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:shieldx/app/core/constants/_assets.dart';
import 'package:shieldx/app/core/constants/_sizes.dart';
import 'package:shieldx/app/core/constants/_strings.dart';
import 'package:shieldx/app/core/theme/_styles.dart';
import 'package:shieldx/app/core/utils/_system_bar_colors.dart';
import 'package:shieldx/app/core/widgets/_custom_button.dart';

import '../../../../core/widgets/_custom_textfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // get theme
    final theme = Theme.of(context).colorScheme;

    // get size
    final size = MediaQuery.of(context).size;

    // set status bar color
    setUiColors(theme);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.sidePadding,
          vertical: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            // logo
            SizedBox(
              height: size.height * 0.4,
              width: size.width,
              child: Image.asset(AppAssets.logosmall, fit: BoxFit.contain),
            ),

            // title
            Text(
              AppStrings.loginTitle,
              style: AppStyles.titleStyle.copyWith(
                color: theme.onSurface,
                fontSize: 20,
              ),
            ),

            // login form
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  // email
                  CustomTextField(
                    hintText: 'Email',
                    prefixIcon: Icon(
                      Icons.email,
                      color: theme.primary,
                      size: 20,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    fillColor: theme.primary.withOpacity(.08),
                    textColor: theme.onSurface,
                    hintColor: theme.onSurface.withOpacity(0.5),
                    autoFillHints: [
                      AutofillHints.email,
                    ],
                  ),

                  // password
                  CustomTextField(
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock,
                      color: theme.primary,
                      size: 20,
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    fillColor: theme.primary.withOpacity(.08),
                    textColor: theme.onSurface,
                    hintColor: theme.onSurface.withOpacity(0.5),
                    autoFillHints: [
                      AutofillHints.password,
                    ],
                  ),

                  // forgot password
                  Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              'Forgot Password?',
                              style: AppStyles.bodyTextStyle.copyWith(
                                color: theme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))),

                  // login button
                  CustomButton(
                      isLoading: true,
                      text: "Log in",
                      onPressed: () async {},
                      color: theme.primary,
                      textColor: theme.onPrimary),
                ],
              ),
            ),

            // register
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  print('register');
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text.rich(
                    TextSpan(
                      text: 'Don\'t have an account? ',
                      style: AppStyles.bodyTextStyle.copyWith(
                        color: theme.onSurface.withOpacity(.7),
                      ),
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: AppStyles.bodyTextStyle.copyWith(
                            color: theme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // or
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  AppStrings.or,
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: theme.onSurface.withOpacity(.7),
                  ),
                ),
              ),
            ),

            // continue with google
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                // google
                CustomIconCard(
                    theme: theme,
                    text: AppStrings.google,
                    icon: AppAssets.google,
                    onTap: () {}),

                // apple
                CustomIconCard(
                    theme: theme,
                    text: AppStrings.facebook,
                    icon: AppAssets.facebook,
                    onTap: () {}),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomIconCard extends StatelessWidget {
  const CustomIconCard({
    super.key,
    required this.theme,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final ColorScheme theme;
  final String text;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
            color: theme.primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            SvgPicture.asset(
              icon,
              height: 30,
              width: 30,
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: AppStyles.bodyTextStyle.copyWith(
                color: theme.onSurface.withOpacity(.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
