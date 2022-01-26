import 'package:discourse/views/settings/settings_controller.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/widgets/switch.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Settings'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
          child: Column(
            children: [
              SettingTile(
                name: 'Notifications',
                onPressed: controller.toNotifs,
              ),
              SizedBox(height: 14),
              SettingTile(
                name: 'Privacy',
                onPressed: controller.toPrivacy,
              ),
              SizedBox(height: 14),
              SettingTile(
                name: 'Change password',
                onPressed: controller.toChangePassword,
              ),
              SizedBox(height: 14),
              SettingTile(
                name: 'Dark theme',
                trailing: MySwitch(
                  defaultValue: true,
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: 36),
              SettingTile(
                name: 'Sign out',
                isDangerous: true,
                onPressed: controller.signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
