import 'dart:async';

import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/chat/chat_log_str.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/utils/ask_block_friend.dart';
import 'package:discourse/utils/ask_leave_group.dart';
import 'package:discourse/utils/ask_remove_friend.dart';
import 'package:discourse/utils/request_friend.dart';
import 'package:discourse/views/chat/controllers/message_list.dart';
import 'package:discourse/views/chat/controllers/message_selection.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/services/chat/whos_typing.dart';
import 'package:discourse/views/group_details/group_details_view.dart';
import 'package:discourse/views/date_selector/date_selector_view.dart';
import 'package:discourse/views/user_profile/user_profile_view.dart';
import 'package:discourse/views/viewed_by/viewed_by_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final _chatLogDb = Get.find<ChatLogDbService>();
  final _commonChatDb = Get.find<CommonChatDbService>();
  final _whosTyping = Get.find<WhosTypingService>();
  final _chatLogStr = Get.find<ChatLogStrService>();
  final _miscCache = Get.find<MiscCache>();

  final messageSelection = Get.find<MessageSelectionController>();

  UserChat get _chat => Get.find<UserChat>();

  String? highlightedMessageId;
  bool showSearchBar = false;

  // bool get isSelectingMessages => _messageSelection.isSelecting;
  // int get numMessagesSelected => _messageSelection.selectedMessages.length;
  bool get isPrivateChat =>
      _chat is UserPrivateChat ||
      _chat is NonExistentChat; // temporary function
  Member member(DiscourseUser user) => _chat.groupData.members.firstWhere(
        (m) => m.user == user,
        orElse: () => Member.removed(user),
      );

  @override
  void onReady() async {
    onStartReading();
  }

  @override
  void onClose() {
    onStopReading();
  }

  void onStartReading() {
    if (_chat is NonExistentChat) return;
    _commonChatDb.startReadingChat(_chat.id);
  }

  // TODO: check if turning off phone or other stuff calls this
  void onStopReading() {
    // when the user is no longer looking at the chat log
    if (_chat is NonExistentChat) return;
    _commonChatDb.stopReadingChat(_chat.id);
  }

  Stream<String?> typingTextStream() => _whosTyping.typingTextStream(_chat.id);

  void toChatDetails() async {
    if (_chat is NonExistentChat) return;
    onStopReading();
    if (_chat is UserPrivateChat) {
      await Get.to(UserProfileView(
        user: (_chat as UserPrivateChat).otherUser,
      ));
    } else {
      await Get.to(GroupDetailsView(chat: _chat as UserGroupChat));
    }
    onStartReading();
  }

  void showChatOptions() async {
    final choice = await Get.bottomSheet(ChoiceBottomSheet(
      title: 'Chat options',
      choices: [
        'Find in chat',
        'Go to date',
        'Export history',
        'Clear chat',
        (_chat is UserGroupChat)
            ? 'Leave group'
            : (_miscCache.myFriends
                    .contains((_chat as UserPrivateChat).otherUser)
                ? 'Remove friend'
                : 'Request friend'),
        if (_chat is UserPrivateChat) 'Block',
      ],
    ));
    if (choice == null) return;
    switch (choice) {
      case 'Find in chat':
        showSearchBar = true;
        update();
        break;
      case 'Go to date':
        Get.find<MessageListController>().toSelectDate();
        break;
      case 'Export history':
        // TODO
        final chatStr = await _chatLogStr.chatLogAsStr(_chat.id);
        print(chatStr);
        break;
      case 'Clear chat':
        // only for admin?
        break;
      case 'Leave group':
        askLeaveGroup(_chat.id);
        break;
      case 'Request friend':
        requestFriend((_chat as UserPrivateChat).otherUser.id);
        break;
      case 'Remove friend':
        askRemoveFriend((_chat as UserPrivateChat).otherUser, update);
        break;
      case 'Block':
        askBlockFriend((_chat as UserPrivateChat).otherUser, update);
        break;
    }
  }

  void toMessageViewedBy() async {
    if (_chat is! UserGroupChat) return;
    onStopReading();
    final message = messageSelection.selectedMessages.single;
    final viewedBy = await _chatLogDb.getViewedBy(
      _chat as UserGroupChat,
      message.sentTimestamp,
    );
    await Get.to(ViewedByView(viewedBy: viewedBy));
    onStartReading();
  }

  void highlightMessage(String messageId) {
    highlightedMessageId = messageId;
    update();
    Future.delayed(Duration(seconds: 1), () {
      highlightedMessageId = null;
      update();
    });
  }
}
