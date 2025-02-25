import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shieldx/app/core/constants/_assets.dart';
import 'package:shieldx/app/core/constants/_sizes.dart';
import 'package:shieldx/app/core/constants/_strings.dart';
import 'package:shieldx/app/core/theme/_styles.dart';
import '../../../../core/utils/_system_bar_colors.dart';
import '../../../../core/widgets/_custom_button.dart';
import '../../controller/_onboard_controller.dart';

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
                      Image.asset(
                        controller.getImage(index),
                        fit: BoxFit.contain,
                        height: size.height * 0.4,
                      ),
                      const SizedBox(height: 20),
                      Padding(
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
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (dotIndex) => Obx(() {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: 10,
                              width: controller.currentPage.value == dotIndex
                                  ? 30
                                  : 10,
                              decoration: BoxDecoration(
                                  color:
                                      controller.currentPage.value == dotIndex
                                          ? theme.primary
                                          : theme.onSurface.withOpacity(.3),
                                  // shape: BoxShape.circle,
                                  borderRadius: BorderRadius.circular(500)),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() {
                            return CustomButton(
                              text: controller.currentPage.value < 2
                                  ? AppStrings.next
                                  : AppStrings.getStarted,
                              onPressed: controller.nextPage,
                              color: theme.primary,
                              textColor: theme.onPrimary,
                              width: size.width * 0.5,
                            );
                          }),
                        ],
                      ),
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
