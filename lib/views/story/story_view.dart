import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/views/story/story_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoryView extends StatelessWidget {
  final String title;
  final List<StoryPage> story;

  const StoryView({
    Key? key,
    required this.title,
    required this.story,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoryController>(
      init: StoryController(story),
      builder: (controller) => Scaffold(),
    );
  }
}
