import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/text_field.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoAndName(controller),
              SizedBox(height: 44),
              if (controller.addMembers.isNotEmpty) ...[
                Text(
                  'Add members',
                  style: TextStyle(
                    color: Get.theme.primaryColor.withOpacity(0.4),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: controller.addMembers
                      .map((user) => PhotoOrIcon(
                            size: 60,
                            iconSize: 24,
                            photoUrl: user.photoUrl,
                            placeholderIcon: FluentIcons.person_24_regular,
                          ))
                      .toList(),
                ),
                SizedBox(height: 40),
              ],
              if (controller.sendInvitesTo.isNotEmpty) ...[
                Text(
                  'Send invites to',
                  style: TextStyle(
                    color: Get.theme.primaryColor.withOpacity(0.4),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: controller.sendInvitesTo
                      .map((user) => PhotoOrIcon(
                            size: 60,
                            iconSize: 24,
                            photoUrl: user.photoUrl,
                            placeholderIcon: FluentIcons.person_24_regular,
                          ))
                      .toList(),
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
        ],
      );
}
