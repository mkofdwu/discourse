import 'package:discourse/views/sign_in/sign_in_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/services/auth.dart';

class SettingsController extends GetxController {
  final _auth = Get.find<AuthService>();

  bool get isDarkMode => Get.isDarkMode;

  void toggleDarkMode() {
    Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
    update();
  }

  void signOut() {
    _auth.signOut();
    Get.offAll(SignInView());
    Get.snackbar('Success', 'Signed out successfully');
  }

  void deleteAccount() {
    _auth.deleteAccount();
    Get.offAll(SignInView());
    Get.snackbar('Success', 'Your account has been deleted');
  }
}
