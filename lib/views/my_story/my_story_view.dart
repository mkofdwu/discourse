import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/floating_action_button.dart';
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
        appBar: myAppBar(title: 'Your story'),
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
        // body: ListView.builder(
        //   itemCount: 4,
        // ),
      ),
    );
  }
}
