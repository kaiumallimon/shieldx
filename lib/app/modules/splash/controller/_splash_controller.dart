import 'package:get/get.dart';
import 'package:shieldx/app/local/_onboard_service.dart';

class SplashController extends GetxController{
  void goNext() {
    Future.delayed(const Duration(seconds: 2), () async{

      bool isWatched = await OnboardService().getOnboardStatus();
      
      if (isWatched) {
        Get.offAllNamed('/login');
      } else {
        Get.offAllNamed('/onboard');
      }
    });
  }
}