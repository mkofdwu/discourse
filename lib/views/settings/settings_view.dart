import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/app_info_links.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:get/get.dart';

import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(builder: _builder);
  }

  Widget _builder(SettingsController controller) => Scaffold(
      appBar: AppBar(title: Text('settings')),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckboxField('Notifications', false, (value) {}),
              SizedBox(height: 14),
              _buildCheckboxField(
                'Dark mode',
                controller.isDarkMode,
                (value) => controller.toggleDarkMode(),
              ),
              SizedBox(height: 30),
              _buildDangerButton('Sign out', controller.signOut),
              SizedBox(height: 14),
              _buildDangerButton('Delete account', controller.deleteAccount),
              Spacer(),
              AppInfoLinks(),
            ],
          )));

  Widget _buildCheckboxField(
    String name,
    bool value,
    Function(bool?) onChanged,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 16)),
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(value: value, onChanged: onChanged),
          ),
        ],
      );

  Widget _buildDangerButton(String text, Function onPressed) => PressedBuilder(
        onPressed: onPressed,
        builder: (pressed) => Opacity(
          opacity: pressed ? 0.8 : 1,
          child: Text(
            text,
            style: TextStyle(
              color: Palette.red,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}
