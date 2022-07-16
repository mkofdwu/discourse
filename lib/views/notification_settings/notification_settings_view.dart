import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/setting_tile.dart';
import 'package:discourse/widgets/switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'notification_settings_controller.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationSettingsController>(
      global: false,
      init: NotificationSettingsController(),
      builder: (controller) => Scaffold(
        appBar: myAppBar(title: 'Notification Settings'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Column(
            children: [
              SettingTile(
                name: 'Allow notifications',
                trailing: MySwitch(
                  defaultValue: true,
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
