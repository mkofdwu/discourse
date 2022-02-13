import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'explore_controller.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      global: false,
      init: ExploreController(),
      builder: (controller) => Scaffold(
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
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: controller.searchResults.length,
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
      ),
    );
  }

  Widget _buildSearchTextField(ExploreController controller) => Container(
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

  Widget _buildUserTile(ExploreController controller, DiscourseUser user) =>
      MyListTile(
        iconData: FluentIcons.person_16_regular,
        title: user.username,
        subtitle: user.aboutMe, // should be the user's about
        photoUrl: user.photoUrl,
        onPressed: () => controller.toUserProfile(user),
      );
}
