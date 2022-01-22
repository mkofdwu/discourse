import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/views/activity/activity_view.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:discourse/models/db_objects/user_chat.dart';

class ChatsController extends GetxController {
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _messagesDb = Get.find<MessagesDbService>();
  final _requests = Get.find<RequestsService>();

  Future<bool> hasNewRequests() => _requests.hasNewRequests();

  Future<List<UserChat>> getChats() => _privateChatDb.myPrivateChats();

  void goToActivity() async {
    await Get.to(ActivityView());
    update(); // if all requests have been cleared
  }

  Future<void> newChat() async {
    Get.to(UserSelectorView(
      canSelectMultiple: false,
      onSubmit: (selectedUsers) async {
        final chat = await _privateChatDb.getChatWith(selectedUsers.single);
        Get.off(ChatView(chat: chat));
      },
    ));
  }

  Stream<Message> lastMessageStream(UserChat chat) =>
      _messagesDb.lastMessageStream(chat.id);

  void togglePinChat(UserChat chat) async {
    chat.pinned = !chat.pinned;
    await _privateChatDb.setPinChat(chat.id, chat.pinned);
    update();
  }

  void showChatOptions(UserChat chat) async {
    final choice = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Chat options',
      choices: [
        'View profile',
        chat.pinned ? 'Unpin chat' : 'Pin chat',
        'Remove friend'
      ],
    ));
    if (choice == null) return;
    switch (choice) {
      case 'View profile':
        break;
      case 'Pin chat':
      case 'Unpin chat':
        togglePinChat(chat);
        break;
      case 'Remove friend':
        break;
    }
  }

  void goToChat(UserChat chat) => Get.to(ChatView(chat: chat));
}
