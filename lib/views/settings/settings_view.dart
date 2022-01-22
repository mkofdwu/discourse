import 'package:discourse/views/settings/settings_controller.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
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
      global: false,
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
              OpacityFeedback(
                onPressed: controller.selectPhoto,
                child: PhotoOrIcon(
                  size: 100,
                  iconSize: 36,
                  backgroundColor: Color(0xFF3C3C3C),
                  photoUrl: controller.user.photoUrl,
                  placeholderIcon: FluentIcons.person_28_regular,
                ),
              ),
              SizedBox(height: 32),
              _buildTextField(
                'Username',
                controller.user.username,
                controller.editUsername,
              ),
              SizedBox(height: 24),
              _buildTextField(
                'About me',
                controller.user.aboutMe ?? 'Nothing here yet',
                controller.editAboutMe,
                fontSize: 14,
              ),
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

  Widget _buildTextField(
    String label,
    String value,
    Function() edit, {
    double fontSize = 16,
  }) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Get.theme.primaryColor.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 24),
          OpacityFeedback(
            child: Icon(FluentIcons.edit_20_regular, size: 20),
            onPressed: edit,
          ),
        ],
      );
}
