import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

class FriendsController extends GetxController {
  final _miscCache = Get.find<MiscCache>();
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _relationshipsDb = Get.find<RelationshipsService>();

  List<DiscourseUser> get myFriends => _miscCache.myFriends;

  void showFriendOptions(DiscourseUser user) async {
    final choice = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Friend options',
      choices: const ['Send message', 'Remove friend', 'Block'],
    ));
    if (choice == null) return;
    switch (choice) {
      case 'Send message':
        Get.off(ChatView(chat: await _privateChatDb.getChatWith(user)));
        break;
      case 'Remove friend':
        final confirmed = await Get.bottomSheet(YesNoBottomSheet(
          title: 'Remove friend?',
          subtitle:
              "Are you sure you want to stop being friends with ${user.username}? You'll have to send them a new request if you change your mind",
        ));
        if (confirmed ?? false) {
          await _relationshipsDb.setMutualRelationship(
              user.id, RelationshipStatus.none);
          _miscCache.myFriends.remove(user);
          update();
        }
        break;
      case 'Block':
        final confirmed = await Get.bottomSheet(YesNoBottomSheet(
          title: 'Block friend?',
          subtitle: 'Are you sure you want to block ${user.username}?',
        ));
        if (confirmed ?? false) {
          await _relationshipsDb.blockUser(user.id);
          _miscCache.myFriends.remove(user);
          update();
        }
        break;
    }
  }
}
