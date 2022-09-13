import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/services/requests.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/views/activity/activity_view.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/views/my_story/my_story_view.dart';
import 'package:discourse/views/set_group_details/set_group_details_view.dart';
import 'package:discourse/views/user_selector/user_selector_view.dart';
import 'package:get/get.dart';
import 'package:discourse/models/db_objects/user_chat.dart';

class ChatsController extends GetxController {
  final _commonChatDb = Get.find<CommonChatDbService>();
  final _chatLogDb = Get.find<ChatLogDbService>();
  final _requests = Get.find<RequestsService>();
  final _storyDb = Get.find<StoryDbService>();

  bool isLoading = false;
  bool hasNewRequests = false;
  Map<DiscourseUser, List<StoryPage>> friendsStories = {};
  final myStory = <StoryPage>[].obs;
  List<UserChat> chats = [];
  bool hasNoContent = false;
  final selectedChats = RxList<UserChat>();

  DiscourseUser get currentUser => Get.find<AuthService>().currentUser;
  bool get isSelecting => selectedChats.isNotEmpty;
  bool get allSelected => chats.length == selectedChats.length;
  bool get showPinSelected => selectedChats.every((chat) => !chat.pinned);
  bool get showUnpinSelected => selectedChats.every((chat) => chat.pinned);

  @override
  void onReady() {
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    update();
    hasNewRequests = await _requests.hasNewRequests();
    friendsStories = await _storyDb.friendsStories();
    myStory.clear();
    myStory.addAll(await _storyDb.myStory());
    chats = await _commonChatDb.myChats();
    hasNoContent = friendsStories.isEmpty && chats.isEmpty;
    isLoading = false;
    update();
  }

  void toActivity() async {
    await Get.to(() => ActivityView());
    fetchData(); // if all requests have been cleared
  }

  void newGroup() {
    Get.to(() => UserSelectorView(
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
    await Get.to(() => MyStoryView());
  }

  int seenNum(List<StoryPage> story) {
    return story.fold(0, (total, story) => total + (story.viewedByMe ? 1 : 0));
  }

  Stream<ChatLogObject> streamLastChatObject(UserChat chat) =>
      _chatLogDb.streamLastChatObject(chat.id);

  Stream<int> numUnreadMessagesStream(UserChat chat) =>
      _chatLogDb.numUnreadMessagesStream(chat.id, chat.lastReadAt);

  void tapChat(UserChat chat) {
    if (isSelecting) {
      toggleSelectChat(chat);
    } else {
      Get.to(() => ChatView(chat: chat));
    }
  }

  void toggleSelectChat(UserChat chat) {
    final index = selectedChats.indexOf(chat);
    if (index == -1) {
      selectedChats.add(chat);
    } else {
      selectedChats.removeAt(index);
    }
  }

  void toggleSelectAll() {
    if (allSelected) {
      // should this be the desired behaviour (since it just ends selection)
      selectedChats.clear();
    } else {
      selectedChats.value = List.from(chats);
    }
  }

  void pinSelected() async {
    for (final chat in selectedChats) {
      chat.pinned = true;
      await _commonChatDb.setPinChat(chat.id, true);
    }
    selectedChats.clear();
    update();
  }

  void unpinSelected() async {
    for (final chat in selectedChats) {
      chat.pinned = false;
      await _commonChatDb.setPinChat(chat.id, false);
    }
    selectedChats.clear();
    update();
  }

  void cancelSelection() {
    selectedChats.clear();
  }
}
