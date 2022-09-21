import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/utils/ask_block_friend.dart';
import 'package:discourse/utils/ask_remove_friend.dart';
import 'package:discourse/utils/request_friend.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/chat/chat_view.dart';
import 'package:discourse/views/examine_photo/examine_photo_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController
    with GetTickerProviderStateMixin {
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _relationships = Get.find<RelationshipsService>();
  final _storyDb = Get.find<StoryDbService>();

  final DiscourseUser _user;
  RelationshipStatus? relationship;
  UserChat? _chat;
  List<StoryPage>? userStory;
  double storyBorderScale = 0;

  List<String> get mediaUrls => _chat is NonExistentChat
      ? []
      : (_chat?.privateData.media.map((m) => m.photoUrl).toList() ?? []);

  UserProfileController(this._user);

  @override
  Future<void> onReady() async {
    relationship = await _relationships.relationshipWithMe(_user.id);
    _chat = await _privateChatDb.getChatWith(_user);
    userStory = await _storyDb.getUserStory(_user.id);
    update();

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    final animation = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(controller);
    animation.addListener(() {
      storyBorderScale = animation.value;
      update();
    });
    controller.forward();
  }

  int get storySeenNum {
    if (userStory == null) return 0;
    return userStory!
        .fold(0, (total, story) => total + (story.viewedByMe ? 1 : 0));
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
        sendMessage();
        break;
      case 'Request friend':
        requestFriend(_user.id);
        break;
      case 'Remove friend':
        askRemoveFriend(_user, update);
        break;
      case 'Block':
        askBlockFriend(_user, update);
        break;
    }
  }

  void sendMessage() {
    if (_chat == null) return;
    if (Get.isRegistered<ChatController>()) {
      // profile page probably accessed from group details page or private chat page
      Get.offUntil(
        GetPageRoute(page: () => ChatView(chat: _chat!)),
        (route) => route.isFirst,
      );
    } else {
      Get.to(() => ChatView(chat: _chat!));
    }
  }

  void toExaminePhoto(String photoUrl) {
    Get.to(
      () => ExaminePhotoView(photo: Photo.url(photoUrl)),
      transition: Transition.fadeIn,
    );
  }
}
