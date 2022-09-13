import 'package:discourse/constants/palette.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/views/chats/chats_list.dart';
import 'package:discourse/views/chats/onboarding_view.dart';
import 'package:discourse/widgets/floating_action_button.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/selection_options_bar.dart';
import 'package:discourse/widgets/user_story_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/views/chats/chats_controller.dart';

class ChatsView extends StatelessWidget {
  const ChatsView({Key? key}) : super(key: key);

  ChatsController get controller => Get.find();
  MiscCache get cache => Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatsController>(
      init: ChatsController(),
      builder: (controller) => Scaffold(
        floatingActionButton: controller.hasNoContent
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 12, right: 10),
                child: MyFloatingActionButton(
                  iconData: FluentIcons.people_community_add_20_regular,
                  onPressed: controller.newGroup,
                ),
              ),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: _buildTop(),
                    ),
                    SizedBox(height: 36),
                    if (controller.hasNoContent)
                      OnboardingView()
                    else
                      ..._buildContent(),
                  ],
                ),
              ),
            ),
            _buildChatSelectionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Good ${timeOfDay()}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          OpacityFeedback(
            onPressed: controller.toActivity,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Stack(
                  children: [
                    Icon(FluentIcons.alert_24_regular),
                    Obx(
                      () => !controller.hasNewRequests.value
                          ? SizedBox.shrink()
                          : Positioned(
                              top: 0,
                              right: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Palette.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  List<Widget> _buildContent() => [
        // announcement
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 36),
        //   child: _buildAnnouncement(),
        // ),
        // SizedBox(height: 36),
        //
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stories',
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                FluentIcons.chevron_down_20_filled,
                size: 20,
                color: Colors.white.withOpacity(0.4),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        _buildStories(),
        SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chats',
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                FluentIcons.chevron_down_20_filled,
                size: 20,
                color: Colors.white.withOpacity(0.4),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: cache.chats.isEmpty ? SizedBox.shrink() : ChatsList(),
        ),
      ];

  Widget _buildAnnouncement() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: Palette.black3,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              FluentIcons.info_28_regular,
              color: Palette.orange,
              size: 28,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vestibulum, cras',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Morbi id donec aliquet elit. Volutpat morbi egestas accumsan, non.',
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );

  Widget _buildStories() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 30),
            _buildYourStoryButton(),
            SizedBox(width: 20),
            ...cache.friendsStories.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: UserStoryTile(
                    user: entry.key,
                    story: entry.value,
                    seenNum: controller.seenNum(entry.value),
                  ),
                )),
            SizedBox(width: 30),
          ],
        ),
      );

  Widget _buildYourStoryButton() => OpacityFeedback(
        onPressed: controller.toMyStory,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Palette.orange, width: 3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: PhotoOrIcon(
                      photoUrl: controller.currentUser.photoUrl,
                      placeholderIcon: FluentIcons.person_28_regular,
                      size: 80,
                      iconSize: 28,
                    ),
                  ),
                ),
                Obx(
                  () => cache.myStory.isEmpty
                      ? SizedBox()
                      : Positioned(
                          right: 0,
                          top: 4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Palette.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                cache.myStory.length.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Your story',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _buildChatSelectionBar() => Obx(() => SelectionOptionsBar(
        numSelected: controller.selectedChats.length,
        options: {
          (controller.allSelected
                  ? FluentIcons.select_all_on_24_regular
                  : FluentIcons.select_all_off_20_regular):
              controller.toggleSelectAll,
          if (controller.showPinSelected)
            FluentIcons.pin_20_regular: controller.pinSelected,
          if (controller.showUnpinSelected)
            FluentIcons.pin_off_20_regular: controller.unpinSelected,
          FluentIcons.archive_24_regular: () {},
        },
        onDismiss: controller.cancelSelection,
      ));
}
