import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersGrid extends StatelessWidget {
  final List<DiscourseUser> users;
  final Function(DiscourseUser) removeUser;

  const UsersGrid({
    Key? key,
    required this.users,
    required this.removeUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 20,
      children: users
          .map((user) => Stack(
                children: [
                  Positioned(
                    left: 6,
                    top: 6,
                    right: 6,
                    bottom: 6,
                    child: PhotoOrIcon(
                      radius: 32,
                      iconSize: 24,
                      photoUrl: user.photoUrl,
                      placeholderIcon: FluentIcons.person_24_regular,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildRemoveButton(() => removeUser(user)),
                  ),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildRemoveButton(Function() onPressed) => OpacityFeedback(
        onPressed: onPressed,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Color(0xFF505050),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Get.theme.scaffoldBackgroundColor,
              width: 4,
            ),
          ),
          child: Center(
            child: Icon(FluentIcons.dismiss_12_regular, size: 12),
          ),
        ),
      );
}
