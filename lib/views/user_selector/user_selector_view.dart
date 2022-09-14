import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/button.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_selector_controller.dart';

class UserSelectorView extends StatelessWidget {
  final String title;
  final String prompt;
  final bool canSelectMultiple;
  final List<DiscourseUser>? onlyUsers; // only select from within this list
  final List<DiscourseUser>? excludeUsers;
  final Function(List<DiscourseUser>) onSubmit;

  const UserSelectorView({
    Key? key,
    required this.title,
    this.prompt = "Enter someone's username to start searching",
    required this.canSelectMultiple,
    this.onlyUsers,
    this.excludeUsers,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserSelectorController>(
      global: false,
      init: UserSelectorController(canSelectMultiple, onlyUsers, excludeUsers),
      builder: _builder,
    );
  }

  Widget _builder(UserSelectorController controller) => Scaffold(
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Row(
                  children: [
                    MyIconButton(
                      FluentIcons.chevron_left_24_filled,
                      onPressed: Get.back,
                    ),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: _buildSearchTextField(controller),
              ),
              if (controller.searchController.text.isEmpty)
                if (onlyUsers == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: Text(
                      prompt,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.2),
                      ),
                    ),
                  )
                else
                  // if showing limited list of users (e.g. selecting from list
                  // of friends) show all of them at the start
                  Expanded(child: _buildResultsList(controller, onlyUsers!)),
              if (controller.searchResults.isNotEmpty && onlyUsers == null)
                Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 12),
                  child: Text(
                    '${controller.searchResults.length} results',
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.4),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (controller.searchResults.isNotEmpty)
                Expanded(
                  child:
                      _buildResultsList(controller, controller.searchResults),
                ),
              if (controller.searchController.text.isNotEmpty &&
                  controller.searchResults.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/undraw_empty.png',
                          width: 160,
                        ),
                        SizedBox(height: 40),
                        Text(
                          "Couldn't find anyone...",
                          style: TextStyle(
                            color: Get.theme.primaryColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _buildSearchTextField(UserSelectorController controller) => Container(
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

  Widget _buildResultsList(
    UserSelectorController controller,
    List<DiscourseUser> results,
  ) =>
      ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        itemCount: results.length,
        itemBuilder: (context, i) {
          final user = results[i];
          return MyListTile(
            iconData: FluentIcons.person_16_regular,
            compact: true,
            title: user.username,
            subtitle: user.aboutMe,
            photoUrl: user.photoUrl,
            isSelected: controller.selectedUsers.contains(user),
            onPressed: () => controller.toggleSelectUser(user),
          );
        },
      );
}
