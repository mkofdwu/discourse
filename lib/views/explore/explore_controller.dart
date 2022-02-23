import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/views/user_profile/user_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _userDb = Get.find<UserDbService>();

  final searchController = TextEditingController();

  List<DiscourseUser> searchResults = [];
  List<DiscourseUser> suggestions = [];

  ExploreController();

  @override
  Future<void> onReady() async {
    searchController.addListener(() {
      refreshResults();
      update();
    });
    suggestions = await getFriendSuggestions(8);
    update();
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

  // random testing / experimentation
  Future<List<DiscourseUser>> getFriendSuggestions(int numSuggestions) {
    // should be transferred to server in the future
    final suggestions = <String, int>{};
    final friendIds = Get.find<MiscCache>().myFriends.map((user) => user.id);

    if (friendIds.isEmpty) {
      // return popular/sponsored users
      return Future.wait([
        'W0Mn0UOAsARJqfs4mest2iMIZKC2',
        'RoYxKuzJ2GSVialKzs73ia9m8ih1',
        'YttvM3cphFRfSKjgSAbmQOHsMio1'
      ].map((id) => _userDb.getUser(id)));
    }

    for (final friend in Get.find<MiscCache>().myFriends) {
      final friendsFriends = friend.relationships.entries
          .where((entry) => entry.value == RelationshipStatus.friend);
      for (final entry in friendsFriends) {
        final userId = entry.key;
        if (userId == _auth.id) continue;
        if (friendIds.contains(userId)) continue;
        suggestions[userId] = suggestions[userId] ?? 0 + 1;
      }
    }
    final list = suggestions.entries.toList();
    list.sort((a, b) => a.value.compareTo(b.value));
    return Future.wait(
      list
          .sublist(0, numSuggestions)
          .map((entry) => _userDb.getUser(entry.key)),
    );
  }

  void dismissSuggestion(DiscourseUser user) {
    suggestions.remove(user);
    update();
  }
}
