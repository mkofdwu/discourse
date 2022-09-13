import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/custom_form/custom_form.dart';
import 'package:discourse/views/custom_form/custom_form_view.dart';
import 'package:discourse/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();
  final _cache = Get.find<MiscCache>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool signingUp;
  bool isLoading = false;

  Map<String, String> inputErrors = {};

  SignInController(this.signingUp);

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
      await _cache.fetchData();
      Get.off(HomeView());
    } else {
      inputErrors = errors;
      update();
    }
  }

  Future<void> _signUp() async {
    final username = await Get.to(
      () => CustomFormView(
        form: CustomForm(
          title: 'Account details',
          fields: [
            Field(
              'username',
              '',
              textFieldBuilder(label: 'Username', isLast: true),
            ),
          ],
          onSubmit: (inputs, setErrors) async {
            final username = inputs['username'] as String;
            if (username.isEmpty) {
              setErrors({'username': 'Please enter a username'});
            } else if (await _userDb.getUserByUsername(username) != null) {
              setErrors({'username': 'This username is already taken'});
            } else {
              Get.back(result: username);
            }
          },
        ),
      ),
    );
    if (username == null) return;
    final errors = await _auth.signUp(
      email: emailController.text,
      username: username,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
    if (errors.isEmpty) {
      await _cache.fetchData();
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
