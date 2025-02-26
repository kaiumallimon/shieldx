import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shieldx/app/core/bindings/_app_bindings.dart';
import 'package:shieldx/app/core/routes/_app_routes.dart';
import 'package:shieldx/app/core/theme/_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().dark,
      initialBinding: AppBindings(),
      initialRoute: '/',
      getPages: appRoutes,
    );
  }
}
