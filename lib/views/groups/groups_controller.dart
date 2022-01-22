import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/views/set_group_details/set_group_details_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:get/get.dart';

class GroupsController extends GetxController {
  final _groupChatDb = Get.find<GroupChatDbService>();
  final _messagesDb = Get.find<MessagesDbService>();

  Future<List<UserGroupChat>> groupChats() => _groupChatDb.myGroupChats();

  Stream<Message> lastMessageStream(UserChat chat) =>
      _messagesDb.lastMessageStream(chat.id);

  void newGroup() {
    Get.to(UserSelectorView(
      canSelectMultiple: true,
      onSubmit: (selectedUsers) async {
        Get.off(SetGroupDetailsView(members: selectedUsers));
      },
    ));
  }

  void goToChat(UserGroupChat chat) => Get.to(ChatView(chat: chat));
}
