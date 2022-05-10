import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/views/user_profile/user_profile_view.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'group_details_controller.dart';

double lerp(double from, double to, double extent) {
  return from + extent * (to - from);
}

String? _memberRoleToString(MemberRole role) {
  switch (role) {
    case MemberRole.owner:
      return 'owner';
    case MemberRole.admin:
      return 'admin';
    default:
      return null;
  }
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
            _buildAppBar(controller),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
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
                      child: chat.groupData.description.isEmpty
                          ? Row(
                              children: const [
                                Icon(
                                  FluentIcons.add_16_regular,
                                  color: Palette.orange,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add description',
                                  style: TextStyle(
                                    color: Palette.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Text(chat.groupData.description),
                      onPressed: controller.editNameAndDescription,
                    ),
                    SizedBox(height: 40),
                    Text(
                      '${chat.groupData.members.length} members',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),
                    MyListTile(
                      title: 'You',
                      subtitle: controller.currentUser.aboutMe,
                      tag: _memberRoleToString(controller.currentUserRole),
                      iconData: FluentIcons.person_16_regular,
                    ),
                    ...chat.groupData.members
                        .where(
                            (member) => member.user != controller.currentUser)
                        .map(
                          (member) => MyListTile(
                            title: member.user.username,
                            subtitle: member.user.aboutMe,
                            tag: _memberRoleToString(member.role),
                            iconData: FluentIcons.person_16_regular,
                            suffixIcons: {
                              if (controller.hasAdminPrivileges)
                                FluentIcons.more_vertical_20_regular: () =>
                                    controller.showMemberOptions(member),
                            },
                            onPressed: () {
                              Get.to(UserProfileView(user: member.user));
                            },
                          ),
                        ),
                    if (controller.hasAdminPrivileges) SizedBox(height: 24),
                    if (controller.hasAdminPrivileges)
                      _buildAddMembersButton(controller),
                    SizedBox(height: 40),
                    if (chat.data.mediaUrls.isNotEmpty) ...[
                      Text(
                        'Photos & videos',
                        style: TextStyle(
                          color: Get.theme.primaryColor.withOpacity(0.4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildPhotosAndVideosList(controller),
                      SizedBox(height: 40),
                    ],
                    _buildDangerButton(
                      'Leave group',
                      FluentIcons.sign_out_20_regular,
                      controller.leaveGroup,
                    ),
                    if (controller.hasAdminPrivileges) SizedBox(height: 12),
                    if (controller.hasAdminPrivileges)
                      _buildDangerButton(
                        'Disband group',
                        FluentIcons.delete_20_regular,
                        controller.deleteGroup,
                      ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(GroupDetailsController controller) => SliverAppBar(
        expandedHeight: 280,
        collapsedHeight: 76,
        elevation: 0,
        pinned: true,
        automaticallyImplyLeading: false,
        backgroundColor: Get.theme.primaryColorLight,
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            final current =
                constraints.biggest.height - Get.mediaQuery.padding.top;
            final extent = (current - 76) / (280 - 76);
            // hacky solution to get full control
            return Stack(
              children: [
                FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: controller.viewGroupPhoto,
                    child: chat.photoUrl != null
                        ? Hero(
                            tag: chat.photoUrl!,
                            child: Image.network(
                              chat.photoUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            color: Palette.orange.withOpacity(0.6),
                            child: Icon(
                              FluentIcons.people_community_28_regular,
                              color: Colors.white.withOpacity(0.1),
                              size: 96,
                            ),
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
                                // TODO
                                'Created by you, 19/04/2021',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: lerp(12, 14, extent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (controller.hasAdminPrivileges)
                          MyIconButton(
                            FluentIcons.edit_24_regular,
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
                      top: lerp(20, 44, extent),
                      left: lerp(24, 50, extent),
                    ),
                    child: extent < 0.1
                        ? MyIconButton(
                            FluentIcons.chevron_left_24_regular,
                            onPressed: Get.back,
                          )
                        : _buildBackButton(extent),
                  ),
                ),
              ],
            );
          },
        ),
      );

  Widget _buildBackButton(double extent) => PressedBuilder(
        onPressed: Get.back,
        builder: (pressed) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(pressed ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                FluentIcons.chevron_left_20_regular,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'BACK',
                style: TextStyle(
                  color: Colors.white.withOpacity(lerp(0, 1, extent)),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.4,
                  // shadows: [
                  //   Shadow(
                  //     blurRadius: 14,
                  //     color: Colors.black.withOpacity(0.25),
                  //   ),
                  // ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildAddMembersButton(GroupDetailsController controller) =>
      OpacityFeedback(
        onPressed: controller.toAddMembers,
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

  Widget _buildPhotosAndVideosList(GroupDetailsController controller) =>
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chat.data.mediaUrls.reversed
                  .take(min(3, chat.data.mediaUrls.length))
                  .map<Widget>((photoUrl) => OpacityFeedback(
                        onPressed: () => controller.toExaminePhoto(photoUrl),
                        child: Hero(
                          tag: photoUrl,
                          child: Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ))
                  .toList() +
              [
                if (chat.data.mediaUrls.length > 3)
                  OpacityFeedback(
                    onPressed: controller.toPhotosAndVideos,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Palette.black2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (chat.data.mediaUrls.length - 3).toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            FluentIcons.chevron_right_16_regular,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
