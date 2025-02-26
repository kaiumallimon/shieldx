import 'package:flutter/material.dart';
import 'package:shieldx/app/core/constants/_sizes.dart';
import 'package:shieldx/app/core/widgets/_custom_button.dart';

import '../../../../core/constants/_assets.dart';
import '../../../../core/constants/_strings.dart';
import '../../../../core/theme/_styles.dart';
import '../../../../core/utils/_system_bar_colors.dart';
import '../../../../core/widgets/_custom_textfield.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // get theme
    final theme = Theme.of(context).colorScheme;

    // get size
    final size = MediaQuery.of(context).size;

    // set status bar color
    setUiColors(theme);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.sidePadding,
          vertical: 5,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // appbar
            SliverAppBar(
              backgroundColor: theme.surface,
              elevation: 0,
              floating: true,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              expandedHeight: AppSize.appBarHeight,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.onSurface,
                ),
              ),
              toolbarHeight: AppSize.appBarHeight,
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: size.height * 0.3,
                width: size.width,
                child: Image.asset(AppAssets.logosmall, fit: BoxFit.contain),
              ),
            ),

            // title
            SliverToBoxAdapter(
              child: Text(
                AppStrings.registerTitle,
                style: AppStyles.titleStyle.copyWith(
                  color: theme.onSurface,
                  fontSize: 20,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: const SizedBox(height: 10),
            ),

            SliverToBoxAdapter(
              child: Text(
                AppStrings.registerSubTitle,
                style: AppStyles.subtitleStyle.copyWith(
                  color: theme.onSurface.withOpacity(.5),
                  fontSize: 14,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: const SizedBox(height: 20),
            ),

            // register form
            SliverToBoxAdapter(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    // name
                    CustomTextField(
                      controller: TextEditingController(),
                      hintText: AppStrings.name,
                      prefixIcon: Icon(
                        Icons.person,
                        color: theme.primary,
                      ),
                      fillColor: theme.onSurface.withOpacity(.1),
                      textColor: theme.onSurface,
                      hintColor: theme.onSurface.withOpacity(.5),
                    ),
                    // email
                    CustomTextField(
                      controller: TextEditingController(),
                      hintText: AppStrings.email,
                      prefixIcon: Icon(
                        Icons.email,
                        color: theme.primary,
                      ),
                      fillColor: theme.onSurface.withOpacity(.1),
                      textColor: theme.onSurface,
                      hintColor: theme.onSurface.withOpacity(.5),
                    ),

                    // password
                    CustomTextField(
                      controller: TextEditingController(),
                      hintText: AppStrings.password,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: theme.primary,
                      ),
                      fillColor: theme.onSurface.withOpacity(.1),
                      textColor: theme.onSurface,
                      hintColor: theme.onSurface.withOpacity(.5),
                    ),

                    // confirm password
                    CustomTextField(
                      controller: TextEditingController(),
                      hintText: AppStrings.confirmPasswordHint,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: theme.primary,
                      ),
                      fillColor: theme.onSurface.withOpacity(.1),
                      textColor: theme.onSurface,
                      hintColor: theme.onSurface.withOpacity(.5),
                    ),

                    // register button

                    CustomButton(
                        text: AppStrings.register,
                        onPressed: () async {},
                        color: theme.primary,
                        textColor: theme.onPrimary),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



