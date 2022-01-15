import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
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
        appBar: myAppBar(title: 'New group'),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoAndName(),
              SizedBox(height: 44),
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
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoAndName() => Row();
}
