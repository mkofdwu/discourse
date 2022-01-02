import 'package:discourse/views/group_details/group_details_view.dart';
import 'package:discourse/widgets/yesno_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/models/message.dart';
import 'package:discourse/models/user_chat.dart';
import 'package:discourse/services/chat/chat_export_service.dart';
import 'package:discourse/services/chat_db.dart';
import 'package:discourse/services/chat/message_selection_service.dart';
import 'package:discourse/services/chat/message_sender_service.dart';

class ChatController extends GetxController {
  final _chatDb = Get.find<ChatDbService>();
  final _messageSenderService = Get.find<MessageSenderService>();
  final _messageSelectionService = Get.find<MessageSelectionService>();
  final _chatExportService = Get.find<ChatExportService>();

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
  bool get isSelectingMessages => _messageSelectionService.isSelecting;
  int get numMessagesSelected =>
      _messageSelectionService.selectedMessages.length;
  bool get isPrivateChat => _userChat is UserPrivateChat;

  ScrollController get scrollController => _scrollController;
  bool get showGoToBottomArrow =>
      _scrollController.hasClients ? _scrollController.offset > 100 : false;

  ChatController(this._userChat);

  @override
  void onReady() {
    _chatDb.currentChat = _userChat;
    // FIXME: undesirable temporary fix
    _messageSenderService.textController.text = '';
    _messageSenderService.photo = null;
    _messageSenderService.repliedMessage = null;
    _messageSenderService.unsentMessages.clear();
    streamMoreMessages();
    // _messageSelectionService.selectedMessages.onChange.listen((event) {
    //   update();
    // });
    _scrollController.addListener(() => update());
  }

  Stream<String?> typingTextStream() => _chatDb.typingTextStream(_userChat.id);

  void goToChatDetails() {
    Get.to(GroupDetailsView());
  }

  void exportChat() {
    _chatExportService.exportChat(_userChat);
  }

  Future<void> leaveChat() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Leave chat?',
      subtitle: 'Are you sure you want to leave?',
    ));
    if (confirmed) {
      _chatDb.leaveChat(_userChat.id);
    }
  }

  // messages list

  void streamMoreMessages() {
    _numMessages += 40;
    _isLoadingMessages = true;
    update();
    _chatDb.streamMessages(_userChat.id, _numMessages).listen((messages) {
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
      _messageSelectionService.selectedMessages
          .every((message) => message.fromMe);

  bool get canReplyToSelectedMessages =>
      _messageSelectionService.selectedMessages.length == 1;

  Future<void> deleteSelectedMessages() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Delete $numMessagesSelected messages?',
      subtitle:
          "Once you press delete, the messages will be gone forever. You won't be able to undo this action!",
    ));
    if (confirmed) {
      await _chatDb.deleteMessages(_messageSelectionService.selectedMessages);
      _messageSelectionService.cancelSelection();
    }
  }

  void replyToSelectedMessages() {
    _messageSenderService.repliedMessage =
        _messageSelectionService.selectedMessages.single.asRepliedMessage();
    _messageSelectionService.cancelSelection();
  }

  void cancelMessageSelection() {
    _messageSelectionService.cancelSelection();
  }
}
