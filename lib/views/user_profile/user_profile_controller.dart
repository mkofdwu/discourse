import 'package:discourse/models/unsent_request.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _requests = Get.find<RequestsService>();
  final _relationships = Get.find<RelationshipsService>();

  final DiscourseUser _user;
  RelationshipStatus? relationship;

  UserProfileController(this._user);

  @override
  Future<void> onReady() async {
    relationship = await _relationships.relationshipWithMe(_user.id);
    update();
  }

  void showProfileOptions() async {
    final choice = await Get.bottomSheet(ChoiceBottomSheet(
      title: _user.username,
      choices: [
        'Send message',
        relationship == RelationshipStatus.friend
            ? 'Remove friend'
            : 'Request friend',
        'Block',
      ],
    ));
    switch (choice) {
      case 'Send message':
        final chat = await _privateChatDb.getChatWith(_user);
        if (Get.isRegistered<ChatController>()) {
          // profile page probably accessed from group details page
          // or private chat page
          // hacky solution
          while (Get.isRegistered<ChatController>()) {
            Get.back();
          }
        }
        Get.to(ChatView(chat: chat));
        break;
      case 'Request friend':
        await _requests.sendRequest(UnsentRequest(
          toUserId: _user.id,
          type: RequestType.friend,
          data: null,
        ));
        Get.snackbar('Success', 'Your friend request has been sent');
        break;
      case 'Block':
        break;
    }
  }
}
