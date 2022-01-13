import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/user_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class UserFinderController extends GetxController {
  final _userDb = Get.find<UserDbService>();

  final searchController = TextEditingController();

  final bool _canSelectMultiple;
  List<DiscourseUser> searchResults = [];
  List<DiscourseUser> selectedUsers = [];

  UserFinderController(this._canSelectMultiple);

  @override
  void onReady() {
    searchController.addListener(() {
      refreshResults();
      update();
    });
  }

  Future<void> refreshResults() async {
    searchResults = await _userDb.searchForUsers(searchController.text);
    update();
  }

  void clearSearch() {
    searchController.text = '';
  }

  Future<void> toggleSelectUser(DiscourseUser user) async {
    if (_canSelectMultiple) {
      if (selectedUsers.contains(user)) {
        selectedUsers.remove(user);
      } else {
        selectedUsers.add(user);
      }
    } else {
      if (selectedUsers.contains(user)) {
        selectedUsers = [];
      } else {
        selectedUsers = [user];
      }
    }
    update();
  }
}
