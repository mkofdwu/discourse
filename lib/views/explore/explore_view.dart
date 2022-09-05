import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'explore_controller.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({Key? key}) : super(key: key);

  ExploreController get controller => Get.find<ExploreController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExploreController>(
      init: ExploreController(),
      builder: (controller) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchTextField(),
                SizedBox(height: 24),
                if (controller.searchController.text.isEmpty)
                  Expanded(child: _buildSuggestions()),
                if (controller.searchResults.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 18, top: 12),
                    child: Text(
                      '${controller.searchResults.length} results',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.4),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      // padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, i) {
                        final user = controller.searchResults[i];
                        return _buildUserTile(user);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTextField() => Container(
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
                  hintText: 'Find someone',
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

  Widget _buildUserTile(DiscourseUser user) => MyListTile(
        iconData: FluentIcons.person_16_regular,
        title: user.username,
        subtitle: user.aboutMe, // should be the user's about
        photoUrl: user.photoUrl,
        onPressed: () => controller.toUserProfile(user),
        increaseWidthFactor: false,
        compact: true,
      );

  Widget _buildSuggestions() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            _buildAllSuggestionsButton(),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.68, // hardcoded magic value
                ),
                itemCount: controller.suggestions.length,
                itemBuilder: (context, i) {
                  final user = controller.suggestions[i];
                  return _buildSuggestionCard(user);
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildAllSuggestionsButton() => OpacityFeedback(
        onPressed: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Palette.black3,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'All suggestions',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Palette.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'We found ${controller.suggestions.length} people you may know',
                      style: TextStyle(
                        color: Get.theme.primaryColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(FluentIcons.chevron_right_20_regular, size: 20),
            ],
          ),
        ),
      );

  Widget _buildSuggestionCard(DiscourseUser user) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Palette.black2,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
            child: Column(
              children: [
                PhotoOrIcon(
                  photoUrl: user.photoUrl,
                  placeholderIcon: FluentIcons.person_28_regular,
                  size: 80,
                  iconSize: 32,
                  iconOpacity: 0.6,
                ),
                SizedBox(height: 16),
                Text(
                  user.username,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                if (user.aboutMe != null) SizedBox(height: 6),
                if (user.aboutMe != null)
                  Text(
                    user.aboutMe!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                // SizedBox(height: 16),
                Spacer(),
                OpacityFeedback(
                  onPressed: () => controller.toUserProfile(user),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Palette.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'View profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: OpacityFeedback(
              onPressed: () => controller.dismissSuggestion(user),
              child: Icon(FluentIcons.dismiss_16_regular, size: 16),
            ),
          ),
        ],
      );
}
