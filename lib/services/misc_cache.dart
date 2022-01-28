import 'package:discourse/models/db_objects/friend_list.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

class MiscCache extends GetxService {
  // this class exists to prevent repeated (expensive) fetching of data
  final _relationships = Get.find<RelationshipsService>();
  final _userDb = Get.find<UserDbService>();
  final _storyDb = Get.find<StoryDbService>();

  List<DiscourseUser> myFriends = [];
  List<FriendList> myFriendLists = [];

  void fetchData() async {
    myFriends = await Future.wait((await _relationships.getFriends())
        .map((userId) => _userDb.getUser(userId)));
    myFriendLists = await _storyDb.myFriendLists();
  }
}
