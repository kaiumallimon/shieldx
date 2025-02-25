import 'package:get/get.dart';

class SplashController extends GetxController{
  void goToLogin() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/onboard');
    });
  }
}