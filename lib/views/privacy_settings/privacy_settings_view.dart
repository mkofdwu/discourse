import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/radio_group.dart';
import 'package:discourse/widgets/setting_tile.dart';
import 'package:discourse/widgets/switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'privacy_settings_controller.dart';

class PrivacySettingsView extends StatelessWidget {
  const PrivacySettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrivacySettingsController>(
      init: PrivacySettingsController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Notification Settings'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: Column(
            children: [
              SettingTile(
                name: 'Public account',
                description:
                    'Allow anyone on this app to find you and view your posts',
                trailing: MySwitch(
                  defaultValue: true,
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: 16),
              SettingTile(
                name: 'Story privacy',
                description: 'Control who can view your stories',
                trailing: SizedBox.shrink(),
                bottom: Align(
                  alignment: Alignment.centerLeft,
                  child: RadioGroup(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
