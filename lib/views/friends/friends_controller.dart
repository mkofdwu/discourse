import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/utils/ask_block_friend.dart';
import 'package:discourse/utils/ask_remove_friend.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

class FriendsController extends GetxController {
  final _miscCache = Get.find<MiscCache>();
  final _privateChatDb = Get.find<PrivateChatDbService>();

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
        askRemoveFriend(user, update);
        break;
      case 'Block':
        askBlockFriend(user, update);
        break;
    }
  }
}
