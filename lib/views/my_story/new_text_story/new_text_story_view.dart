import 'package:discourse/constants/palette.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'new_text_story_controller.dart';

class NewTextStoryView extends StatelessWidget {
  const NewTextStoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewTextStoryController>(
      init: NewTextStoryController(),
      builder: (controller) => Scaffold(
        backgroundColor: Palette.orange, // Color(0xFF314EB2),
        floatingActionButton: PressedBuilder(
          onPressed: controller.submit,
          builder: (pressed) => Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(bottom: 10, right: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Icon(
                FluentIcons.send_20_regular,
                size: 20,
                color: pressed ? Palette.orange : Colors.white,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.28],
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            OpacityFeedback(
                              child: Icon(
                                FluentIcons.chevron_left_24_regular,
                                size: 24,
                              ),
                              onPressed: () => Get.back(),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'New story',
                              style: TextStyle(
                                height: 1.4,
                                fontFamily: 'Avenir',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 36),
                        Expanded(
                          child: TextField(
                            controller: controller.textController,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: "What's on your mind?",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                            maxLines: 12,
                            autofocus: true,
                            cursorColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  color: Colors.black.withOpacity(0.2),
                  child: Row(
                    children: [
                      SizedBox(width: 36),
                      Text(
                        'Send to 15 people',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
