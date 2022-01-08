import 'package:discourse/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final _auth = Get.find<AuthService>();

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool signingUp = false;
  bool isLoading = false;

  Map<String, String> inputErrors = {};

  void toggleSigningUp() {
    signingUp = !signingUp;
    update();
  }

  Future<void> _signIn() async {
    final errors = await _auth.signIn(
      email: emailController.text,
      password: passwordController.text,
    );
    if (errors.isEmpty) {
      Get.off(HomeView());
    } else {
      inputErrors = errors;
      update();
    }
  }

  Future<void> _signUp() async {
    final errors = await _auth.signUp(
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    if (errors.isEmpty) {
      Get.off(HomeView());
    } else {
      inputErrors = errors;
      update();
    }
  }

  Future<void> submit() async {
    isLoading = true;
    update();
    await (signingUp ? _signUp() : _signIn());
    isLoading = false;
    update();
  }
}
