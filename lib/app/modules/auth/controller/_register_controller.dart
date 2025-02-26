import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shieldx/app/core/widgets/_custom_alert.dart';
import 'package:shieldx/app/modules/auth/data/repository/_register_repository.dart';

class RegisterController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void goBack() => Get.back();

  var isLoading = false.obs;

  Future<void> register() async {
    if (!validateInputs()) return;

    try {
      isLoading.value = true;

      var response = await RegisterRepository().register(data: {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
      });

      isLoading.value = false;

      if (response['status'] == 'success') {
        Get.offAllNamed('/login');
        showAlert(
          title: "Success",
          message: response['message'],
          isError: false,
          onConfirm: goBack,
        );

        // Clear input fields
        clearInputs();
      } else {
        showAlert(
          title: "Error",
          message: response['message'] ?? "Registration failed",
          isError: true,
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      isLoading.value = false;
      showAlert(
        title: "Error",
        message: "An unexpected error occurred: ${e.toString()}",
        isError: true,
        onConfirm: () => Get.back(),
      );
    }
  }

  bool validateInputs() {
    String? errorMessage;

    if (nameController.text.trim().isEmpty) {
      errorMessage = "Please enter your name";
    } else if (emailController.text.trim().isEmpty) {
      errorMessage = "Please enter your email";
    } else if (passwordController.text.isEmpty) {
      errorMessage = "Please enter your password";
    } else if (confirmPasswordController.text.isEmpty) {
      errorMessage = "Please confirm your password";
    } else if (passwordController.text != confirmPasswordController.text) {
      errorMessage = "Passwords do not match";
    }

    if (errorMessage != null) {
      showAlert(
        title: "Error",
        message: errorMessage,
        isError: true,
        onConfirm: () => Get.back(),
      );
      return false;
    }

    return true;
  }

  void clearInputs() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
