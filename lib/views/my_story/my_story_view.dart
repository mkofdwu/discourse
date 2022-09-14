import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/widgets/animated_list.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/floating_action_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/selection_options_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_story_controller.dart';

class MyStoryView extends StatelessWidget {
  const MyStoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyStoryController>(
      init: MyStoryController(),
      builder: (controller) => Material(
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: myAppBar(
                title: 'Your story',
                actions: {FluentIcons.eye_24_regular: controller.viewMyStory},
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 16, right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyFloatingActionButton(
                      iconData: FluentIcons.edit_24_regular,
                      onPressed: controller.newTextPost,
                    ),
                    SizedBox(height: 20),
                    MyFloatingActionButton(
                      iconData: FluentIcons.camera_24_regular,
                      isPrimary: false,
                      onPressed: controller.newPhotoPost,
                    ),
                  ],
                ),
              ),
              body: Obx(
                () => controller.myStory.isEmpty
                    ? _buildPlaceholder(controller)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 24, top: 24),
                            child: Text(
                              'Click to view, long press for more options',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: MyAnimatedList(
                              controller: controller.listAnimationController,
                              list: controller.myStory,
                              listTileBuilder: (i, story) {
                                story as StoryPage;
                                return Obx(
                                  // for selected state
                                  () => MyListTile(
                                    increaseWidthFactor: false,
                                    title: '${story.viewedAt.length} views',
                                    subtitle: formatTime(story.sentTimestamp),
                                    photoUrl: story.type == StoryType.photo
                                        ? story.content
                                        : null,
                                    iconData:
                                        FluentIcons.text_description_20_regular,
                                    isSelected: controller.selectedStories
                                        .contains(story),
                                    onPressed: () =>
                                        controller.onTapStory(story),
                                    onLongPress: () =>
                                        controller.toggleSelectStory(story),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Obx(() => SelectionOptionsBar(
                  numSelected: controller.selectedStories.length,
                  options: {
                    if (controller.selectedStories.length == 1)
                      FluentIcons.eye_24_regular: controller.showViewedBy,
                    if (controller.selectedStories.length == 1)
                      FluentIcons.edit_24_regular: controller.editSelectedStory,
                    FluentIcons.delete_24_regular:
                        controller.deleteSelectedStories,
                  },
                  onDismiss: controller.cancelSelection,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(MyStoryController controller) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/undraw_blank_canvas.png',
                width: 160,
              ),
              SizedBox(height: 42),
              Text(
                "You don't have any stories yet. Click the button below to add one",
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      );
}
