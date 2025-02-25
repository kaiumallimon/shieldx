import 'package:flutter/material.dart';
import 'package:shieldx/app/local/_onboard_service.dart';

import 'app/_app.dart';

void main() async {
  // initialize flutter binding
  // to ensure that the app is fully initialized before running
  WidgetsFlutterBinding.ensureInitialized();

  // initialize hive
  await OnboardService().initialize();

  // run app
  runApp(const MyApp());
}
