import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_selector_controller.dart';

class UserSelectorView extends StatelessWidget {
  final bool canSelectMultiple;
  final Function(List<DiscourseUser>) onSubmit;

  const UserSelectorView({
    Key? key,
    required this.canSelectMultiple,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserFinderController>(
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
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchTextField(controller),
                SizedBox(height: 36),
                if (controller.searchController.text.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    padding: const EdgeInsets.only(left: 32),
                    child: Text(
                      '${controller.searchResults.length} results',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (controller.searchResults.isNotEmpty) SizedBox(height: 22),
                if (controller.searchResults.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      itemCount: controller.searchResults.length,
                      separatorBuilder: (context, i) => SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final user = controller.searchResults[i];
                        return _buildUserTile(controller, user);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

  Widget _buildSearchTextField(UserFinderController controller) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 28),
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
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                style: TextStyle(fontSize: 16),
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
        subtitle: user.email, // should be the user's about
        isSelected: controller.selectedUsers.contains(user),
        onPressed: () => controller.toggleSelectUser(user),
      );
}
