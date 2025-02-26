import 'package:get/get.dart';
import 'package:shieldx/app/modules/auth/view/pages/_login.dart';
import 'package:shieldx/app/modules/auth/view/pages/_register.dart';

import '../../modules/onboard/view/pages/_onboard_page.dart';
import '../../modules/splash/view/pages/_splash_page.dart';

List<GetPage> appRoutes = [
  GetPage(name: '/', page: () => const SplashPage()),
  GetPage(name: '/onboard', page: () => const OnboardPage()),
  GetPage(name: '/login', page: () => const LoginPage()),
  GetPage(name: '/register', page: () => const RegisterPage()),

];
