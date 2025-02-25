import 'package:get/get.dart';

import '../../modules/onboard/view/pages/_onboard_page.dart';
import '../../modules/splash/view/pages/_splash_page.dart';

List<GetPage> appRoutes = [
  GetPage(name: '/', page: () => const SplashPage()),
  GetPage(name: '/onboard', page: () => const OnboardPage()),
];
