import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'group_details_controller.dart';

double lerp(double from, double to, double extent) {
  return from + extent * (to - from);
}

class GroupDetailsView extends StatelessWidget {
  final UserGroupChat chat;

  const GroupDetailsView({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupDetailsController>(
      init: GroupDetailsController(chat),
      builder: (controller) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              collapsedHeight: 76,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Get.theme.primaryColorLight,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final current = constraints.biggest.height -
                      MediaQuery.of(context).padding.top;
                  final extent = (current - 76) / (280 - 76);
                  // hacky solution to get full control
                  return Stack(
                    children: [
                      FlexibleSpaceBar(
                        background: chat.photoUrl != null
                            ? Image.network(
                                chat.photoUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Palette.orange,
                                child: Icon(
                                  FluentIcons.people_community_28_regular,
                                  color: Colors.white.withOpacity(0.1),
                                  size: 96,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            lerp(74, 50, extent),
                            50,
                            lerp(28, 42, extent),
                            lerp(18, 32, extent),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(lerp(0, 0.7, extent)),
                                Colors.black.withOpacity(0),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chat.title,
                                      style: TextStyle(
                                        fontSize: lerp(16, 24, extent),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Created by you, 19/04/2021',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: lerp(12, 14, extent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OpacityFeedback(
                                child: Icon(
                                  FluentIcons.edit_24_regular,
                                  size: lerp(20, 24, extent),
                                ),
                                onPressed: controller.editNameAndDescription,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // this needs to be on top so it can be clicked
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: lerp(28, 44, extent),
                            left: lerp(30, 50, extent),
                          ),
                          child: _buildBackButton(extent),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 42),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Text(
                      'Description',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),
                    OpacityFeedback(
                      child: chat.data.description.isEmpty
                          ? Row(
                              children: [
                                Icon(
                                  FluentIcons.add_16_regular,
                                  color:
                                      Get.theme.primaryColor.withOpacity(0.4),
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add description',
                                  style: TextStyle(
                                    color:
                                        Get.theme.primaryColor.withOpacity(0.4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Text(chat.data.description),
                      onPressed: controller.editNameAndDescription,
                    ),
                    SizedBox(height: 36),
                    Text(
                      '${chat.data.members.length} members',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),
                    ...chat.data.members.map(
                      (member) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MyListTile(
                          title: member.user.username,
                          subtitle: member.user.aboutMe,
                          iconData: FluentIcons.person_16_regular,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildAddMembersButton(controller),
                    SizedBox(height: 36),
                    _buildDangerButton(
                      'Leave group',
                      FluentIcons.sign_out_20_regular,
                      controller.leaveGroup,
                    ),
                    SizedBox(height: 12),
                    _buildDangerButton(
                      'Disband group',
                      FluentIcons.delete_20_regular,
                      controller.deleteGroup,
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(double extent) => OpacityFeedback(
        onPressed: Get.back,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0),
                  ],
                ),
              ),
              child: Icon(
                FluentIcons.chevron_left_20_regular,
                size: 20,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'BACK',
              style: TextStyle(
                color: Colors.white.withOpacity(lerp(0, 1, extent)),
                fontWeight: FontWeight.w500,
                letterSpacing: 1.4,
                shadows: [
                  Shadow(
                    blurRadius: 14,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildAddMembersButton(GroupDetailsController controller) =>
      OpacityFeedback(
        onPressed: controller.goToAddMembers,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Palette.black3,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Get.theme.primaryColor.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Icon(FluentIcons.add_16_filled, size: 16)),
              ),
              SizedBox(width: 16),
              Text(
                'Add members',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );

  Widget _buildDangerButton(
    String text,
    IconData iconData,
    Function() onPressed,
  ) =>
      OpacityFeedback(
        onPressed: onPressed,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Get.theme.primaryColorLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Palette.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(iconData, color: Palette.red, size: 20),
            ],
          ),
        ),
      );
}
