import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:discourse/widgets/choice_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:discourse/models/db_objects/user_chat.dart';

class ChatsController extends GetxController {
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _messagesDb = Get.find<MessagesDbService>();

  bool _loading = false;
  List<UserPrivateChat> _chats = [];

  bool get loading => _loading;
  List<UserPrivateChat> get chats => _chats;

  @override
  Future<void> onReady() async {
    _loading = true;
    update();
    _chats = await _privateChatDb.myPrivateChats();
    _loading = false;
    update();
  }

  Future<void> newChat() async {
    Get.to(UserSelectorView(
      canSelectMultiple: false,
      onSubmit: (selectedUsers) async {
        final userChat = await _privateChatDb.getChatWith(selectedUsers.single);
        Get.to(ChatView(userChat: userChat));
      },
    ));
  }

  Stream<Message> lastMessageStream(UserChat chat) =>
      _messagesDb.lastMessageStream(chat.id);

  void showChatOptions(UserChat chat) => Get.bottomSheet(ChoiceBottomSheet(
        title: 'Chat options',
        choices: const ['View profile', 'Pin chat', 'Remove friend'],
      ));

  void goToChat(UserChat chat) => Get.to(ChatView(userChat: chat));
}
