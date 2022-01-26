import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/story_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendListController extends GetxController {
  final _storyDb = Get.find<StoryDbService>();

  final List<DiscourseUser> _selectedFriends;

  final nameController = TextEditingController();
  String? nameError;

  FriendListController(this._selectedFriends);

  void submit() async {
    if (nameController.text.isEmpty) {
      nameError = 'Please enter a name for this list';
      update();
    } else {
      await _storyDb.newFriendList(
        nameController.text,
        _selectedFriends.map((user) => user.id).toList(),
      );
      Get.back(); // to select friends list
      Get.back(); // to privacy settings view
    }
  }
}
