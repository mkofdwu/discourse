import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/utils/format_date_time.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/floating_action_button.dart';
import 'package:discourse/widgets/list_tile.dart';
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
      builder: (controller) => Scaffold(
        appBar: myAppBar(
          title: 'Your story',
          actions: {FluentIcons.eye_show_20_regular: controller.viewMyStory},
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
                onPressed: controller.newPhotoPost,
              ),
            ],
          ),
        ),
        body: FutureBuilder<List<StoryPage>>(
          future: controller.getMyStory(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
              child: Column(
                children: snapshot.data!
                    .map((story) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: MyListTile(
                            title: '${story.viewedAt.length} views',
                            subtitle: formatTime(story.sentTimestamp),
                            photoUrl: story.type == StoryType.photo
                                ? story.content
                                : null,
                            iconData: FluentIcons.text_description_20_regular,
                            suffixIcons: {
                              FluentIcons.edit_20_regular: () {},
                              FluentIcons.delete_20_regular: () {},
                            },
                            onPressed: () => controller.viewSingleStory(story),
                          ),
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
