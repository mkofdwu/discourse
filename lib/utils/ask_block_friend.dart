import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

Future<void> askBlockFriend(DiscourseUser user, Function() updateUi) async {
  final confirmed = await Get.bottomSheet(YesNoBottomSheet(
    title: 'Block friend?',
    subtitle: 'Are you sure you want to block ${user.username}?',
  ));
  if (confirmed ?? false) {
    await Get.find<RelationshipsService>().blockUser(user.id);
    Get.find<MiscCache>().myFriends.remove(user);
    updateUi();
  }
}
