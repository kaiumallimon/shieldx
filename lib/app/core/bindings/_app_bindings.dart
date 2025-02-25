import 'package:get/get.dart';

import '../../modules/splash/controller/_splash_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Controllers
    Get.lazyPut(() => SplashController());
  }
}