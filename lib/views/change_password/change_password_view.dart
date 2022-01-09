import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'change_password_controller.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
      init: ChangePasswordController(),
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: myAppBar(title: 'Change password'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextField(
                controller: controller.currentPasswordController,
                label: 'Current password',
                obscureText: true,
              ),
              SizedBox(height: 28),
              MyTextField(
                controller: controller.newPasswordController,
                label: 'New password',
                obscureText: true,
              ),
              SizedBox(height: 28),
              MyTextField(
                controller: controller.confirmNewPasswordController,
                label: 'Confirm new password',
                obscureText: true,
              ),
              Spacer(),
              MyButton(text: 'Submit', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
