import 'package:discourse/views/add_participants/add_participants_view.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/views/edit_profile/edit_profile_view.dart';
import 'package:discourse/views/new_group_chat/set_details_view.dart';
import 'package:discourse/views/new_private_chat/new_private_chat_view.dart';
import 'package:discourse/widgets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:discourse/models/user_chat.dart';
import 'package:discourse/services/chat_db.dart';

class HomeController extends GetxController {
  final _chatDb = Get.find<ChatDbService>();

  bool _loading = false;
  List<UserChat> _chats = [];

  bool get loading => _loading;
  List<UserChat> get chats => _chats;

  @override
  Future<void> onReady() async {
    _loading = true;
    update();
    _chats = await _chatDb.getUserChats();
    _loading = false;
    update();
  }

  Future<void> newChat() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Create new chat',
      subtitle: 'Do you want to talk to someone privately or create a group?',
    ));
    if (confirmed) {
      Get.to(NewPrivateChatView());
    } else {
      final users = await Get.to(AddParticipantsView());
      Get.to(NewGroupSetDetailsView(users: users));
    }
  }

  void goToEditProfile() => Get.to(EditProfileView());

  void goToChat(UserChat userChat) => Get.to(ChatView(userChat: userChat));
}
