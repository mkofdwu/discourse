import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/views/group_details/app_bar.dart';
import 'package:discourse/views/user_profile/user_profile_view.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'group_details_controller.dart';

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
      builder: (controller) => DefaultTabController(
        length: 4,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: GroupDetailsAppBar(chat: chat),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _membersTab(controller),
                _photosAndVideosTab(controller),
                _linksTab(controller),
                _filesTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _membersTab(GroupDetailsController controller) => Builder(
        builder: (context) {
          return CustomScrollView(
            key: PageStorageKey('membersList'),
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Text(
                      '${chat.groupData.members.length} members',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 14),
                    if (controller.hasAdminPrivileges)
                      MyListTile(
                        title: 'Add members',
                        subtitle: null,
                        iconData: FluentIcons.add_20_filled,
                        isActionTile: true,
                        onPressed: controller.toAddMembers,
                      ),
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
                            onPressed: () {
                              Get.to(() => UserProfileView(user: member.user));
                            },
                            onLongPress: () =>
                                controller.showMemberOptions(member),
                          ),
                        ),
                  ]),
                ),
              ),
            ],
          );
        },
      );

  Widget _photosAndVideosTab(GroupDetailsController controller) => Builder(
        builder: (context) {
          return CustomScrollView(
            key: PageStorageKey('mediaList'),
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              chat.data.media.isEmpty
                  ? _buildPlaceholder()
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final media = chat.data.media[i];
                            return OpacityFeedback(
                              onPressed: () => controller.toExaminePhoto(media),
                              child: Hero(
                                tag: media.photoUrl,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    imageUrl: media.photoUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: chat.data.media.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                      ),
                    ),
            ],
          );
        },
      );

  Widget _linksTab(GroupDetailsController controller) => Builder(
        builder: (context) {
          return CustomScrollView(
            key: PageStorageKey('linksList'),
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              chat.data.links.isEmpty
                  ? _buildPlaceholder()
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final link = chat.data.links[i];
                            final listTile = MyListTile(
                              title: link.data.title,
                              subtitle: link.data.description,
                              photoUrl: link.data.photoUrl,
                              iconData: FluentIcons.link_20_regular,
                              onPressed: () {
                                launchUrlString(
                                  link.url,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              extraWidgets: [
                                MyIconButton(
                                  FluentIcons.arrow_circle_right_24_regular,
                                  onPressed: () {
                                    controller.showLinkInChat(link.messageId);
                                  },
                                ),
                              ],
                            );
                            return i == 0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${chat.data.links.length} links',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 14),
                                      listTile,
                                    ],
                                  )
                                : listTile;
                          },
                          childCount: chat.data.links.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      );

  Widget _filesTab() => Container(height: 10, color: Colors.yellow);

  Widget _buildPlaceholder() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/undraw_empty.png',
            width: 160,
          ),
          SizedBox(height: 40),
          Text(
            "Nothing here...",
            style: TextStyle(
              color: Get.theme.primaryColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
