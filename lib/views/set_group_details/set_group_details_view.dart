import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/users_grid.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'set_group_details_controller.dart';

class SetGroupDetailsView extends StatelessWidget {
  final List<DiscourseUser> members;

  const SetGroupDetailsView({
    Key? key,
    required this.members,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SetGroupDetailsController>(
      init: SetGroupDetailsController(members),
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: myAppBar(title: 'New group'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoAndName(controller),
              SizedBox(height: 44),
              if (controller.addMembers.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      'Add members',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    _buildAddButton('Friends', controller.addFriends),
                  ],
                ),
                SizedBox(height: 24),
                Expanded(
                  child: UsersGrid(
                    users: controller.addMembers,
                    removeUser: controller.removeAddMember,
                  ),
                ),
                SizedBox(height: 40),
              ],
              if (controller.sendInvitesTo.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      'Send invites to',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    _buildAddButton('Invite more', controller.inviteMore),
                  ],
                ),
                SizedBox(height: 24),
                Expanded(
                  child: UsersGrid(
                    users: controller.sendInvitesTo,
                    removeUser: controller.removeInvite,
                  ),
                ),
              ],
              Spacer(),
              Center(
                child: MyButton(
                  text: 'Create group',
                  onPressed: controller.submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoAndName(SetGroupDetailsController controller) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpacityFeedback(
            onPressed: controller.selectPhoto,
            child: PhotoOrIcon(
              size: 60,
              iconSize: 24,
              photoFile: controller.photo?.file,
              photoUrl: controller.photo?.url,
              placeholderIcon: FluentIcons.image_add_24_regular,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: controller.nameController,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Palette.black2,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: controller.nameError,
                  isDense: true,
                  contentPadding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  hintText: 'Group name',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Get.theme.primaryColor.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildAddButton(String text, Function() onPressed) => OpacityFeedback(
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
          decoration: BoxDecoration(
            color: Palette.black2,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                FluentIcons.add_16_regular,
                color: Palette.orange,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: Palette.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}
