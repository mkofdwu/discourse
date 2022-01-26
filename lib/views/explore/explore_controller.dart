import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/user_profile/user_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  final searchController = TextEditingController();

  List<DiscourseUser> searchResults = [];

  ExploreController();

  @override
  void onReady() {
    searchController.addListener(() {
      refreshResults();
      update();
    });
  }

  Future<void> refreshResults() async {
    searchResults = await _userDb.searchForUsers(
      searchController.text,
      _auth.id,
    );
    update();
  }

  void clearSearch() {
    searchController.text = '';
  }

  void toUserProfile(DiscourseUser user) {
    Get.to(UserProfileView(user: user));
  }
}
