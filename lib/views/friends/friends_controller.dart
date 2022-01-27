import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

class FriendsController extends GetxController {
  final _relationships = Get.find<RelationshipsService>();
  final _userDb = Get.find<UserDbService>();

  Future<List<DiscourseUser>> getFriends() async =>
      Future.wait((await _relationships.getFriends())
          .map((userId) => _userDb.getUser(userId)));

  void showFriendOptions(DiscourseUser user) {
    // TODO
  }
}
