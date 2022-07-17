import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:discourse/widgets/button.dart';
import 'package:get/get.dart';

import 'sign_in_controller.dart';

class SignInView extends StatelessWidget {
  final bool signUp;

  const SignInView({Key? key, this.signUp = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(
      global: false,
      init: SignInController(signUp),
      builder: (SignInController controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.signingUp ? 'Sign up' : 'Sign in',
                  style: TextStyle(
                    color: Palette.orange,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: controller.signingUp
                        ? 'Enter your email below to begin. Already have an account? '
                        : "Please enter your email and password. Don't have an account? ",
                    style: TextStyle(fontFamily: 'Avenir', height: 1.3),
                    children: [
                      TextSpan(
                        text: controller.signingUp ? 'Sign in' : 'Sign up',
                        style: TextStyle(
                          color: Palette.orange,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = controller.toggleSigningUp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                MyTextField(
                  controller: controller.emailController,
                  label: 'Email',
                  error: controller.inputErrors['email'],
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  obscureText: true,
                  error: controller.inputErrors['password'],
                  onSubmit: controller.signingUp ? null : controller.submit,
                ),
                if (controller.signingUp) SizedBox(height: 20),
                if (controller.signingUp)
                  MyTextField(
                    controller: controller.confirmPasswordController,
                    label: 'Confirm password',
                    obscureText: true,
                    error: controller.inputErrors['confirmPassword'],
                    onSubmit: controller.submit,
                  ),
                Spacer(),
                MyButton(
                  text: controller.signingUp ? 'Continue' : 'Submit',
                  isLoading: controller.isLoading,
                  onPressed: controller.submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
