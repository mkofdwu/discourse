import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendListController extends GetxController {
  final _miscCache = Get.find<MiscCache>();

  late List<DiscourseUser> friends;

  final nameController = TextEditingController();
  String? nameError;

  FriendListController(String name, List<DiscourseUser> friends) {
    nameController.text = name;
    this.friends = List.from(friends);
    update();
  }

  void addFriends() async {
    // only show friends that have not been added to list
    final unselectedFriends = _miscCache.myFriends
        .where((user) => !friends.any((selected) => selected.id == user.id))
        .toList();
    Get.to(UserSelectorView(
      title: 'Add friends',
      canSelectMultiple: true,
      onlyUsers: unselectedFriends,
      onSubmit: (selectedUsers) {
        friends.addAll(selectedUsers);
        Get.back();
        update();
      },
    ));
  }

  void removeFriend(DiscourseUser user) {
    friends.remove(user);
    update();
  }

  void submit() async {
    if (nameController.text.isEmpty) {
      nameError = 'Please enter a name for this list';
      update();
    } else {
      Get.back(result: {'name': nameController.text, 'friends': friends});
    }
  }
}
