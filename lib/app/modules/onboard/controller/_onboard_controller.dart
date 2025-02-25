import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/_assets.dart';
import '../../../core/constants/_strings.dart';

class OnboardController extends GetxController {
  var currentPage = 0.obs;
  final PageController pageController = PageController();

  void changePage(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.animateToPage(
        currentPage.value + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Navigate to home or login page
      Get.offAllNamed('/login');
    }
  }

  String getImage(int index) {
    return [
      AppAssets.onboarding1,
      AppAssets.onboarding2,
      AppAssets.onboarding3,
    ][index];
  }

  String getTitle(int index) {
    return [
      AppStrings.onboardingTitle1,
      AppStrings.onboardingTitle2,
      AppStrings.onboardingTitle3,
    ][index];
  }

  String getSubtitle(int index) {
    return [
      AppStrings.onboardingSubTitle1,
      AppStrings.onboardingSubTitle2,
      AppStrings.onboardingSubTitle3,
    ][index];
  }
}
