import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shieldx/app/core/widgets/_custom_alert.dart';
import 'package:shieldx/app/modules/auth/data/repository/_login_repository.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void goToRegister() {
    Get.toNamed('/register');
  }

  var isLoading = false.obs;

  final LoginRepository _loginRepository = LoginRepository();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // validate inputs
      if (!validate()) return;

      // show loading indicator
      isLoading.value = true;

      // call login
      final response = await _loginRepository.login(
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response['status'] == 'success') {
        // store tokens
        await _loginRepository.storeTokens(
          accessToken: response['data']['accessToken'],
          refreshToken: response['data']['refreshToken'],
        );

        // hide loading indicator
        isLoading.value = false;

        // fetch post login data
        

        // navigate to home
      } else {
        // hide loading indicator
        isLoading.value = false;
        showAlert(
            title: "Error",
            message: response['message'],
            isError: true,
            onConfirm: () {
              Get.back();
            });
      }
    } catch (e) {
      showAlert(
          title: "Error",
          message: e.toString(),
          isError: true,
          onConfirm: () {
            Get.back();
          });
    }
  }

  bool validate() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showAlert(
          title: "Error",
          message: "Please fill all fields",
          isError: true,
          onConfirm: () {
            Get.back();
          });
      return false;
    }
    return true;
  }
}
