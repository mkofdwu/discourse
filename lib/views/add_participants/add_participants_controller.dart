import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/models/user.dart';

class AddParticipantsController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  final searchController = TextEditingController();

  final List<String> _excludeUserIds;

  List<DiscourseUser> _searchResults = [];
  final List<DiscourseUser> _selectedUsers = [];

  List<DiscourseUser> get searchResults => _searchResults;
  List<DiscourseUser> get selectedUsers => _selectedUsers;

  AddParticipantsController(this._excludeUserIds);

  @override
  void onReady() {
    searchController.addListener(() {
      refreshResults();
      update();
    });
  }

  Future<void> refreshResults() async {
    final results = await _userDb.searchForUsers(searchController.text);
    _searchResults = results
        .where((user) =>
            !_excludeUserIds.contains(user.id) && user != _auth.currentUser)
        .toList();
    update();
  }

  void clearSearch() {
    searchController.text = '';
  }

  Future<void> toggleParticipant(DiscourseUser user) async {
    if (_selectedUsers.contains(user)) {
      _selectedUsers.remove(user);
    } else {
      _selectedUsers.add(user);
    }
    update();
  }

  void submit() {
    Get.back(result: _selectedUsers);
  }
}
