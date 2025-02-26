import 'package:get/get.dart';
import 'package:shieldx/app/modules/auth/controller/_login_controller.dart';
import 'package:shieldx/app/modules/onboard/controller/_onboard_controller.dart';

import '../../modules/splash/controller/_splash_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Controllers
    Get.lazyPut(() => SplashController());
    Get.lazyPut(() => OnboardController());
    Get.lazyPut(() => LoginController());
  }
}
