import 'dart:async';

import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/views/chat/controllers/message_list.dart';
import 'package:discourse/views/chat/controllers/message_selection.dart';
import 'package:discourse/views/chat/controllers/message_sender.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/chat_export.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:discourse/services/chat/whos_typing.dart';
import 'package:discourse/views/group_details/group_details_view.dart';
import 'package:discourse/views/date_selector/date_selector_view.dart';
import 'package:discourse/views/user_profile/user_profile_view.dart';
import 'package:discourse/views/viewed_by/viewed_by_view.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final _messagesDb = Get.find<MessagesDbService>();
  final _groupChatDb = Get.find<GroupChatDbService>();
  final _commonChatDb = Get.find<CommonChatDbService>();
  final _whosTyping = Get.find<WhosTypingService>();
  final _chatExport = Get.find<ChatExportService>();
  final _miscCache = Get.find<MiscCache>();

  final _messageSender = Get.find<MessageSenderController>();
  final _messageSelection = Get.find<MessageSelectionController>();
  final _messageList = Get.find<MessageListController>();

  final UserChat _chat;

  bool get isSelectingMessages => _messageSelection.isSelecting;
  int get numMessagesSelected => _messageSelection.selectedMessages.length;
  bool get isPrivateChat => _chat is UserPrivateChat; // temporary function
  Member member(DiscourseUser user) => _chat.groupData.members.firstWhere(
        (m) => m.user == user,
        orElse: () => Member.removed(user),
      );

  // or just expose messageList?
  List<Message> get messages => _messageList.messages;
  ScrollController get scrollController => _messageList.scrollController;
  bool get showGoToBottomArrow => _messageList.showGoToBottomArrow;
  int get numNewMessages => _messageList.numNewMessages;
  GlobalKey messageKey(String messageId) => _messageList.messageKey(messageId);
  void scrollToBottom() => _messageList.scrollToBottom();

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
        break;
      case 'Request friend':
        break;
      case 'Remove friend':
        break;
      case 'Block':
        break;
    }
  }

  void toMessageViewedBy() async {
    if (_chat is! UserGroupChat) return;
    onStopReading();
    final message = _messageSelection.selectedMessages.single;
    final viewedBy =
        await _messagesDb.getViewedBy(_chat as UserGroupChat, message);
    await Get.to(ViewedByView(viewedBy: viewedBy));
    onStartReading();
  }

  void toSelectDate() async {
    final date = await Get.to(DateSelectorView(title: 'Go to date'));
  }

  void exportChat() {
    _chatExport.exportChat(_chat);
  }

  Future<void> leaveChat() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Leave chat?',
      subtitle:
          'Are you sure you want to leave this chat? You will need someone to add you back in afterwards.',
    ));
    if (confirmed ?? false) {
      _groupChatDb.leaveGroup(_chat.id);
    }
  }

  // selected messages

  bool get canDeleteSelectedMessages =>
      _messageSelection.selectedMessages.every((message) => message.fromMe);

  bool get canReplyToSelectedMessages =>
      _messageSelection.selectedMessages.length == 1;

  bool get canGoToViewedBy =>
      _chat is UserGroupChat &&
      _messageSelection.selectedMessages.length == 1 &&
      _messageSelection.selectedMessages.single.fromMe;

  Future<void> deleteSelectedMessages() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Delete $numMessagesSelected messages?',
      subtitle:
          "Once you press delete, the messages will be gone forever. You won't be able to undo this action!",
    ));
    if (confirmed ?? false) {
      await _messagesDb.deleteMessages(_messageSelection.selectedMessages);
      final photoUrls = _messageSelection.selectedMessages
          .where((message) => message.photo != null)
          .map((message) => message.photo!.url!)
          .toList();
      await _commonChatDb.deletePhotos(photoUrls, _chat);
      for (final photoUrl in photoUrls) {
        _chat.data.mediaUrls.remove(photoUrl);
      }
      _messageSelection.cancelSelection();
    }
  }

  void replyToSelectedMessages() {
    _messageSender.repliedMessage.value =
        _messageSelection.selectedMessages.single.asRepliedMessage();
    _messageSelection.cancelSelection();
  }

  void cancelMessageSelection() {
    _messageSelection.cancelSelection();
  }
}
