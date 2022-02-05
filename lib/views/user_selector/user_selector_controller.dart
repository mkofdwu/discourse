import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class UserSelectorController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  final searchController = TextEditingController();

  final bool _canSelectMultiple;
  final List<DiscourseUser>? _onlyUsers;
  final List<DiscourseUser>? _excludeUsers;
  List<DiscourseUser> searchResults = [];
  List<DiscourseUser> selectedUsers = [];

  UserSelectorController(
    this._canSelectMultiple,
    this._onlyUsers,
    this._excludeUsers,
  );

  @override
  void onReady() {
    searchController.addListener(() {
      refreshResults();
      update();
    });
  }

  Future<void> refreshResults() async {
    final query = searchController.text;
    if (query.isEmpty) {
      searchResults = [];
      update();
      return;
    }
    if (_onlyUsers != null) {
      searchResults = _onlyUsers!
          .where((user) =>
              user.username.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
    } else {
      searchResults = await _userDb.searchForUsers(query, _auth.id);
    }
    if (_excludeUsers != null) {
      searchResults = searchResults
          .where((user) => !_excludeUsers!.contains(user))
          .toList();
    }
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
