import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

class BlockedUsersController extends GetxController {
  final _relationships = Get.find<RelationshipsService>();
  final _userDb = Get.find<UserDbService>();
  final _miscCache = Get.find<MiscCache>();

  Future<List<DiscourseUser>> blockedUsers() async =>
      Future.wait((await _relationships.getBlockedUsers())
          .map((userId) => _userDb.getUser(userId)));

  void unblockUser(DiscourseUser user) async {
    final rs = await _relationships.unblockUser(user.id);
    if (rs == RelationshipStatus.friend) {
      _miscCache.myFriends.add(user);
    }
    update();
  }
}
