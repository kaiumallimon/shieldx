import 'package:hive_flutter/hive_flutter.dart';

class OnboardService{
  // save onboard status in hive
  Future<void> saveOnboardStatus(bool status) async {
    final box = await Hive.openBox('onboard');
    await box.put('status', status);
  }

  // get onboard status from hive
  Future<bool> getOnboardStatus() async {
    final box = await Hive.openBox('onboard');
    return box.get('status', defaultValue: false);
  }

  // initialize method
  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox('onboard');
  }
}