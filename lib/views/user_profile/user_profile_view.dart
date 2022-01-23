import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/views/user_profile/user_profile_controller.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileView extends StatelessWidget {
  final DiscourseUser user;

  const UserProfileView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      global: false,
      init: UserProfileController(user),
      builder: (controller) => Scaffold(
        appBar: myAppBar(
          title: 'User profile',
          actions: {
            FluentIcons.more_vertical_20_regular: controller.showProfileOptions,
          },
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Center(
            child: Column(
              children: [
                PhotoOrIcon(
                  size: 160,
                  iconSize: 64,
                  photoUrl: user.photoUrl,
                  placeholderIcon: FluentIcons.person_48_regular,
                ),
                SizedBox(height: 28),
                Text(
                  '@' + user.username,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                if (controller.relationship == RelationshipStatus.friend)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'FRIEND',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                if (user.aboutMe != null) ...[
                  SizedBox(height: 40),
                  Text(
                    'About me',
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(user.aboutMe!),
                ],
                SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
