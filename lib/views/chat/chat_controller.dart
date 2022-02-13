import 'dart:async';

import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/utils/ask_block_friend.dart';
import 'package:discourse/utils/ask_leave_group.dart';
import 'package:discourse/utils/ask_remove_friend.dart';
import 'package:discourse/utils/request_friend.dart';
import 'package:discourse/views/chat/controllers/message_selection.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/chat_export.dart';
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
  final _chatExport = Get.find<ChatExportService>();
  final _miscCache = Get.find<MiscCache>();

  final messageSelection = Get.find<MessageSelectionController>();

  final UserChat _chat;

  String? highlightedMessageId;

  // bool get isSelectingMessages => _messageSelection.isSelecting;
  // int get numMessagesSelected => _messageSelection.selectedMessages.length;
  bool get isPrivateChat => _chat is UserPrivateChat; // temporary function
  Member member(DiscourseUser user) => _chat.groupData.members.firstWhere(
        (m) => m.user == user,
        orElse: () => Member.removed(user),
      );

  ChatController(this._chat);

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
    onStopReading();
    if (isPrivateChat) {
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
        break;
      case 'Go to date':
        break;
      case 'Export history':
        _chatExport.exportChat(_chat);
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

  void exportChat() {
    _chatExport.exportChat(_chat);
  }

  Future<void> leaveChat() async {}

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
