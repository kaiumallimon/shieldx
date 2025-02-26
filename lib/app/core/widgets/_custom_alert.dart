import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showAlert({
  required String title,
  required String message,
  required bool isError,
  required Function() onConfirm,
}) {
  final theme = Get.theme.colorScheme;

  Get.snackbar(title, message,
      backgroundColor: isError ? theme.error : theme.primary,
      colorText: isError ? theme.onError : theme.onPrimary,
      //never closes automatically
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      mainButton: TextButton(
        onPressed: onConfirm,
        child: Text(
          'OK',
          style: TextStyle(color: isError ? theme.onError : theme.onPrimary),
        ),
      ),
      margin: const EdgeInsets.all(20));
}
