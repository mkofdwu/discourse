import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/views/activity/activity_view.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/views/my_story/my_story_view.dart';
import 'package:discourse/views/set_group_details/set_group_details_view.dart';
import 'package:discourse/views/story/story_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:discourse/models/db_objects/user_chat.dart';

class ChatsController extends GetxController {
  final _commonChatDb = Get.find<CommonChatDbService>();
  final _messagesDb = Get.find<MessagesDbService>();
  final _requests = Get.find<RequestsService>();
  final _storyDb = Get.find<StoryDbService>();

  Future<bool> hasNewRequests() => _requests.hasNewRequests();

  Future<List<UserChat>> getChats() => _commonChatDb.myChats();

  void toActivity() async {
    await Get.to(ActivityView());
    update(); // if all requests have been cleared
  }

  void newGroup() {
    Get.to(UserSelectorView(
      title: 'Select members',
      prompt:
          "Find members to add to this group. If you aren't friends with a person an invite will be sent to them",
      canSelectMultiple: true,
      onSubmit: (selectedUsers) async {
        Get.off(SetGroupDetailsView(members: selectedUsers));
      },
    ));
  }

  void toMyStory() async {
    await Get.to(MyStoryView());
    update();
  }

  Future<int> numMyStories() async => (await _storyDb.myStory()).length;

  Future<Map<DiscourseUser, List<StoryPage>>> getFriendsStories() =>
      _storyDb.friendsStories();

  int seenNum(List<StoryPage> story) {
    return story.fold(0, (total, story) => total + (story.viewedByMe ? 1 : 0));
  }

  void viewStory(DiscourseUser user, List<StoryPage> story) {
    Get.to(StoryView(title: "${user.username}'s story", story: story));
  }

  Stream<Message> lastMessageStream(UserChat chat) =>
      _messagesDb.lastMessageStream(chat.id);

  Stream<int> numUnreadMessagesStream(UserChat chat) =>
      _messagesDb.numUnreadMessagesStream(chat.id, chat.lastReadAt);

  void showChatOptions(UserChat chat) async {
    // TODO: update these
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

  void togglePinChat(UserChat chat) async {
    chat.pinned = !chat.pinned;
    await _commonChatDb.setPinChat(chat.id, chat.pinned);
    update();
  }

  void toChat(UserChat chat) => Get.to(() => ChatView(chat: chat));
}
