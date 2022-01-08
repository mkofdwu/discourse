import 'package:discourse/views/settings/settings_controller.dart';
import 'package:discourse/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (controller) => Container(
        child: MyButton(
          text: 'Sign out',
          onPressed: controller.signOut,
        ),
      ),
    );
  }
}
