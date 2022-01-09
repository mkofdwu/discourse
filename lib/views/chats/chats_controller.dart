import 'package:discourse/widgets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat_db.dart';

class ChatsController extends GetxController {
  final _chatDb = Get.find<ChatDbService>();

  bool _loading = false;
  List<UserPrivateChat> _chats = [];

  bool get loading => _loading;
  List<UserPrivateChat> get chats => _chats;

  @override
  Future<void> onReady() async {
    _loading = true;
    update();
    _chats = await _chatDb.myPrivateChats();
    _loading = false;
    update();
  }

  Future<void> newChat() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Create new chat',
      subtitle: 'Do you want to talk to someone privately or create a group?',
    ));
    // if (confirmed ?? false) {
    //   Get.to(NewPrivateChatView());
    // } else {
    //   final users = await Get.to(AddMembersView());
    //   Get.to(NewGroupSetDetailsView(users: users));
    // }
  }

  void goToChat(UserChat userChat) =>
      null; // Get.to(ChatView(userChat: userChat));
}
