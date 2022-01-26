import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_selector_controller.dart';

class UserSelectorView extends StatelessWidget {
  final String title;
  final bool canSelectMultiple;
  final Function(List<DiscourseUser>) onSubmit;

  const UserSelectorView({
    Key? key,
    required this.title,
    required this.canSelectMultiple,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserFinderController>(
      global: false,
      init: UserFinderController(canSelectMultiple),
      builder: _builder,
    );
  }

  Widget _builder(UserFinderController controller) => Scaffold(
        floatingActionButton: controller.selectedUsers.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 14, right: 14),
                child: MyButton(
                  text: controller.selectedUsers.length > 1
                      ? '${controller.selectedUsers.length} users selected'
                      : '${controller.selectedUsers.single.username} selected',
                  suffixIcon: FluentIcons.chevron_right_16_filled,
                  onPressed: () => onSubmit(controller.selectedUsers),
                ),
              ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 42),
                child: Row(
                  children: [
                    OpacityFeedback(
                      child:
                          Icon(FluentIcons.chevron_left_20_regular, size: 20),
                      onPressed: Get.back,
                    ),
                    SizedBox(width: 20),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 30),
                child: _buildSearchTextField(controller),
              ),
              if (controller.searchController.text.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: Text(
                    "Enter someone's username to start searching, select a user to start a chat with them.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ),
              if (controller.searchResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Text(
                    '${controller.searchResults.length} results',
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.4),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (controller.searchResults.isNotEmpty) SizedBox(height: 24),
              if (controller.searchResults.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (context, i) => SizedBox(height: 20),
                    itemBuilder: (context, i) {
                      final user = controller.searchResults[i];
                      return _buildUserTile(controller, user);
                    },
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _buildSearchTextField(UserFinderController controller) => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Palette.black3,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              FluentIcons.search_20_regular,
              size: 20,
              color: Get.theme.primaryColor.withOpacity(
                  controller.searchController.text.isEmpty ? 0.4 : 1),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  // contentPadding: EdgeInsets.zero,
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Get.theme.primaryColor.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildUserTile(UserFinderController controller, DiscourseUser user) =>
      MyListTile(
        iconData: FluentIcons.person_16_regular,
        title: user.username,
        subtitle: user.aboutMe, // should be the user's about
        photoUrl: user.photoUrl,
        isSelected: controller.selectedUsers.contains(user),
        onPressed: () => controller.toggleSelectUser(user),
      );
}
