import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void setUiColors(ColorScheme theme) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: theme.surface,
        systemNavigationBarColor: theme.surface,
        statusBarIconBrightness: theme.brightness,
        systemNavigationBarIconBrightness: theme.brightness),
  );
}
