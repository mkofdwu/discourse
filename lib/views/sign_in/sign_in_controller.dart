import 'package:discourse/views/about/about_view.dart';
import 'package:discourse/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final _auth = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Map<String, String> inputErrors = {};

  Future<void> signIn() async {
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

  void goToAbout() => Get.to(AboutView());

  void goToLicenses() => Get.to(LicensePage());
}
