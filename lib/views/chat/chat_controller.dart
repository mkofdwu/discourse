import 'package:discourse/controllers/message_selection.dart';
import 'package:discourse/controllers/message_sender.dart';
import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/models/db_objects/user_settings.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/services/chat/chat_export.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/services/chat/whos_typing.dart';
import 'package:discourse/widgets/choice_bottom_sheet.dart';
import 'package:discourse/widgets/yesno_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final _messagesDb = Get.find<MessagesDbService>();
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _groupChatDb = Get.find<GroupChatDbService>();
  final _whosTyping = Get.find<WhosTypingService>();
  final _messageSender = Get.find<MessageSenderController>();
  final _messageSelection = Get.find<MessageSelectionController>();
  final _chatExport = Get.find<ChatExportService>();

  final UserChat _userChat;

  bool _isLoadingMessages = false;
  int _numMessages = 0;
  List<Message> _messages = [];
  final _messageKeys = <String, GlobalKey>{};
  final _scrollController = ScrollController();

  UserChat get userChat => _userChat;
  bool get isLoadingMessages => _isLoadingMessages;
  List<Message> get messages => _messages;
  GlobalKey messageKey(String messageId) => _messageKeys[messageId]!;
  bool get isSelectingMessages => _messageSelection.isSelecting;
  int get numMessagesSelected => _messageSelection.selectedMessages.length;
  bool get isPrivateChat => _userChat is UserPrivateChat;
  Member member(String userId) => (_userChat as UserGroupChat)
      .data
      .members
      .firstWhere((member) => member.user.id == userId);

  ScrollController get scrollController => _scrollController;
  bool get showGoToBottomArrow =>
      _scrollController.hasClients ? _scrollController.offset > 100 : false;

  ChatController(this._userChat);

  @override
  void onReady() {
    _messageSender.textController.text = '';
    _messageSender.photo.value = Photo.url(
        'https://images.unsplash.com/photo-1642131724313-9fc5eb39a558?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60');
    _messageSender.repliedMessage.value = RepliedMessage(
      id: 'tsaetu',
      sender: DiscourseUser(
        id: 'aeuo',
        email: 'matthew',
        username: 'matthew',
        settings: UserSettings(
          enableNotifications: true,
          showStoryTo: null,
          publicAccount: true,
        ),
        relationships: {},
      ),
      text: 'Lorem ipsum sit dolor amet',
    );
    _messageSender.unsentMessages.clear();
    _scrollController.addListener(() => update());
    streamMoreMessages();
  }

  Stream<String?> typingTextStream() =>
      _whosTyping.typingTextStream(_userChat.id);

  void goToChatDetails() {
    // Get.to(GroupDetails());
  }

  void exportChat() {
    _chatExport.exportChat(_userChat);
  }

  Future<void> leaveChat() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Leave chat?',
      subtitle:
          'Are you sure you want to leave this chat? You will need someone to add you back in afterwards.',
    ));
    if (confirmed) {
      _groupChatDb.leaveGroup(_userChat.id);
    }
  }

  // messages list

  void streamMoreMessages() {
    if (_userChat is NonExistentChat) return;
    _numMessages += 40;
    _isLoadingMessages = true;
    update();
    _messagesDb.streamMessages(_userChat.id, _numMessages).listen((messages) {
      _messages = messages;
      for (final message in _messages) {
        _messageKeys[message.id] = GlobalKey();
      }
      _isLoadingMessages = false;
      update();
    });
  }

  void scrollToMessage(String messageId) {
    if (_messageKeys.containsKey(messageId)) {
      Scrollable.ensureVisible(
        _messageKeys[messageId]!.currentContext!,
        duration: const Duration(milliseconds: 400),
        alignment: 0.8,
      );
    }
  }

  void scrollToBottom() {
    if (_scrollController.offset > 1000) {
      _scrollController.jumpTo(0);
    } else {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    }
  }

  // selected messages

  bool get canDeleteSelectedMessages =>
      _messageSelection.selectedMessages.every((message) => message.fromMe);

  bool get canReplyToSelectedMessages =>
      _messageSelection.selectedMessages.length == 1;

  Future<void> deleteSelectedMessages() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Delete $numMessagesSelected messages?',
      subtitle:
          "Once you press delete, the messages will be gone forever. You won't be able to undo this action!",
    ));
    if (confirmed) {
      await _messagesDb.deleteMessages(_messageSelection.selectedMessages);
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
