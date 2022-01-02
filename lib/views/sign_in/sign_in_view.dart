import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/app_info_links.dart';
import 'package:discourse/widgets/button.dart';
import 'package:get/get.dart';

import 'sign_in_controller.dart';

class SignInView extends StatelessWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(
      builder: _builder,
    );
  }

  Widget _builder(SignInController controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 80,
            bottom: 40,
            left: 60,
            right: 60,
          ),
          child: Column(
            children: [
              Image.asset(
                'assets/images/icon.png',
              ),
              SizedBox(height: 36),
              Text(
                'simple chat',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
              ),
              Spacer(flex: 2),
              _buildTextField(
                controller: controller.emailController,
                hintText: 'Email',
                obscureText: false,
                error: controller.inputErrors['email'],
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: controller.passwordController,
                hintText: 'Password',
                obscureText: true,
                error: controller.inputErrors['password'],
              ),
              SizedBox(height: 18),
              Spacer(),
              MyButton(
                text: 'Sign in',
                onPressed: controller.signIn,
              ),
              SizedBox(height: 60),
              AppInfoLinks(),
            ],
          ),
        ),
      );

  Widget _buildTextField({
    TextEditingController? controller,
    String? hintText,
    required bool obscureText,
    String? error,
  }) {
    final border = OutlineInputBorder(
      borderSide: error != null
          ? BorderSide(color: Palette.red, width: 1)
          : BorderSide.none,
      borderRadius: BorderRadius.circular(10),
    );
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: error,
        filled: true,
        fillColor: Palette.light0,
        enabledBorder: border,
        focusedBorder: border,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      obscureText: obscureText,
    );
  }
}
