import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendListController extends GetxController {
  final _relationships = Get.find<RelationshipsService>();
  final _userDb = Get.find<UserDbService>();

  late List<DiscourseUser> friends;

  final nameController = TextEditingController();
  String? nameError;

  FriendListController(String name, List<DiscourseUser> friends) {
    nameController.text = name;
    this.friends = List.from(friends);
    update();
  }

  void addFriends() async {
    // FIXME: this operation may be very expensive
    // only show friends that have not been added to list
    final unselectedFriends = await Future.wait(
        (await _relationships.getFriends())
            .where((userId) => !friends.any((user) => user.id == userId))
            .map((userId) => _userDb.getUser(userId)));
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
