import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:get/get.dart';

class FriendsController extends GetxController {
  final _miscCache = Get.find<MiscCache>();

  List<DiscourseUser> get myFriends => _miscCache.myFriends;

  void showFriendOptions(DiscourseUser user) {
    // TODO
  }
}
