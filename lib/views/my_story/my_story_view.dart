import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/widgets/animated_list.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/floating_action_button.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_story_controller.dart';

class MyStoryView extends StatelessWidget {
  final List<StoryPage> myStory;

  const MyStoryView({Key? key, required this.myStory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyStoryController>(
      init: MyStoryController(myStory),
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: myAppBar(
          title: 'Your story',
          actions: {FluentIcons.eye_20_regular: controller.viewMyStory},
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyFloatingActionButton(
                iconData: FluentIcons.edit_20_regular,
                onPressed: controller.newTextPost,
              ),
              SizedBox(height: 20),
              MyFloatingActionButton(
                iconData: FluentIcons.camera_20_regular,
                isPrimary: false,
                onPressed: controller.newPhotoPost,
              ),
            ],
          ),
        ),
        body: myStory.isEmpty
            ? _buildPlaceholder(controller)
            : MyAnimatedList(
                controller: controller.listAnimationController,
                list: myStory,
                listTileBuilder: (i, story) {
                  story as StoryPage;
                  return MyListTile(
                    increaseWidthFactor: false,
                    title: '${story.viewedAt.length} views',
                    subtitle: formatTime(story.sentTimestamp),
                    photoUrl:
                        story.type == StoryType.photo ? story.content : null,
                    iconData: FluentIcons.text_description_20_regular,
                    extraWidgets: [
                      MyIconButton(
                        FluentIcons.edit_20_regular,
                        onPressed: () => controller.editStory(story),
                      ),
                      MyIconButton(
                        FluentIcons.delete_20_regular,
                        onPressed: () => controller.deleteStory(i),
                      ),
                    ],
                    onPressed: () => controller.viewSingleStory(story),
                  );
                },
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
              SizedBox(height: 42),
              PressedBuilder(
                onPressed: controller.newTextPost,
                builder: (pressed) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Palette.orange.withOpacity(pressed ? 0.06 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Write something',
                    style: TextStyle(
                      color: Palette.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 70),
            ],
          ),
        ),
      );
}
