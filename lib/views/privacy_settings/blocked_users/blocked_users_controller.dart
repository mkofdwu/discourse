import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

class BlockedUsersController extends GetxController {
  final _relationships = Get.find<RelationshipsService>();
  final _userDb = Get.find<UserDbService>();

  Future<List<DiscourseUser>> blockedUsers() async =>
      Future.wait((await _relationships.getBlockedUsers())
          .map((userId) => _userDb.getUser(userId)));

  void unblockUser(DiscourseUser user) async {
    await _relationships.unblockUser(user.id);
    update();
  }
}
