import 'package:discourse/models/db_objects/friend_list.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/unsent_story.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/views/privacy_settings/friend_list/friend_list_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextStoryController extends GetxController {
  final _storyDb = Get.find<StoryDbService>();
  final _miscCache = Get.find<MiscCache>();

  final StoryPage? _defaultStory;

  FriendList? selectedFriendList; // if null, send to all friends
  final textController = TextEditingController();

  TextStoryController(this._defaultStory) {
    if (_defaultStory != null) textController.text = _defaultStory!.content;
  }

  void changeFriendList() async {
    final choice = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Select friend list',
      choices: ['All friends'] +
          _miscCache.myFriendLists.map((list) => list.name).toList() +
          ['New friend list'],
    ));
    if (choice == null) return;
    if (choice == 'New friend list') {
      await _newFriendList();
      return;
    }
    final friendList = choice == 'All friends'
        ? null
        : _miscCache.myFriendLists.singleWhere((list) => list.name == choice);
    selectedFriendList = friendList;
    update();
  }

  Future<void> _newFriendList() async {
    final result = await Get.to(FriendListView(
      title: 'New friend list',
      listName: '',
      friends: const [],
    ));
    if (result != null) {
      final newList = await _storyDb.newFriendList(
        result['name'],
        result['friends'],
      );
      _miscCache.myFriendLists.add(newList);
      Get.back(); // return to this page
      update();
    }
  }

  void submit() async {
    if (_defaultStory == null) {
      await _storyDb.postStory(UnsentStory(
        type: StoryType.text,
        content: textController.text,
        sendToIds: (selectedFriendList == null
                ? _miscCache.myFriends
                : selectedFriendList!.friends)
            .map((user) => user.id)
            .toList(),
      ));
    } else {
      await _storyDb.updateStory(_defaultStory!.id, textController.text);
    }
    Get.back();
  }
}
