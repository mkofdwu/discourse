import 'package:discourse/models/db_objects/friend_list.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/unsent_story.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewTextStoryController extends GetxController {
  final _storyDb = Get.find<StoryDbService>();
  final _relationships = Get.find<RelationshipsService>();

  FriendList? selectedFriendList; // if null, send to all friends
  final textController = TextEditingController();

  void changeFriendList() {
    // Get.bottomSheet(
    //     ChoiceBottomSheet(title: 'Select friend list', choices: choices));
  }

  void submit() async {
    await _storyDb.postStory(UnsentStory(
      type: StoryType.text,
      content: textController.text,
      sendToIds: selectedFriendList == null
          ? await _relationships.getFriends()
          : selectedFriendList!.friends.map((user) => user.id).toList(),
    ));
    Get.back();
  }
}
