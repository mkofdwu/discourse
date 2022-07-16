import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

Future<void> askRemoveFriend(DiscourseUser user, Function() updateUi) async {
  final confirmed = await Get.bottomSheet(YesNoBottomSheet(
    title: 'Remove friend?',
    subtitle:
        "Are you sure you want to stop being friends with ${user.username}? You'll have to send them a new request if you change your mind",
  ));
  if (confirmed ?? false) {
    await Get.find<RelationshipsService>()
        .setMutualRelationship(user.id, RelationshipStatus.canTalk);
    final miscCache = Get.find<MiscCache>();
    miscCache.myFriends.remove(user);
    // remove from all friend lists
    for (final friendList in miscCache.myFriendLists) {
      if (friendList.friends.contains(user)) {
        friendList.friends.remove(user);
        await Get.find<StoryDbService>().updateFriendList(friendList);
      }
    }
    updateUi();
  }
}
