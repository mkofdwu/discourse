import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/views/settings/settings_controller.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/setting_tile.dart';
import 'package:discourse/widgets/switch.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (controller) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  OpacityFeedback(
                    child: Icon(FluentIcons.sign_out_24_regular),
                    onPressed: controller.signOut,
                  ),
                ],
              ),
              SizedBox(height: 60),
              CircleAvatar(
                radius: 50,
                backgroundImage: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1519011985187-444d62641929?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80'),
              ),
              SizedBox(height: 32),
              _buildUsernameField(controller),
              SizedBox(height: 44),
              if (controller.emailVerified)
                SettingTile(
                  name: 'Email verified',
                  description: controller.user.email,
                  trailing: Icon(FluentIcons.checkmark_16_filled, size: 16),
                )
              else
                SettingTile(
                  name: 'Verify email',
                  onPressed: controller.verifyEmail,
                ),
              SizedBox(height: 14),
              SettingTile(
                name: 'Notifications',
                onPressed: controller.goToNotifs,
              ),
              SizedBox(height: 14),
              SettingTile(
                name: 'Privacy',
                onPressed: controller.goToPrivacy,
              ),
              SizedBox(height: 14),
              SettingTile(
                name: 'Change password',
                onPressed: controller.goToChangePassword,
              ),
              SizedBox(height: 14),
              SettingTile(
                name: 'Dark theme',
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

  Widget _buildUsernameField(SettingsController controller) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username',
                style: TextStyle(
                    color: Get.theme.primaryColor.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                controller.user.username,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Icon(FluentIcons.edit_20_regular, size: 20),
        ],
      );
}
