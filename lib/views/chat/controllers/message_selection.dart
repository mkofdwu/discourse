import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/chat/controllers/message_sender.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

class MessageSelectionController extends GetxController {
  final _messageSender = Get.find<MessageSenderController>();
  final _chatLogDb = Get.find<ChatLogDbService>();
  final _commonChatDb = Get.find<CommonChatDbService>();
  final _storage = Get.find<StorageService>();

  final selectedMessages = <Message>[].obs;

  UserChat get _chat => Get.find<ChatController>().chat;
  bool get isSelecting => selectedMessages.isNotEmpty;
  int get numSelected => selectedMessages.length;
  bool get canDeleteSelectedMessages =>
      selectedMessages.every((message) => message.fromMe);
  bool get canReplyToSelectedMessages => selectedMessages.length == 1;
  bool get canGoToViewedBy =>
      _chat is UserGroupChat &&
      selectedMessages.length == 1 &&
      selectedMessages.single.fromMe;

  void toggleSelectMessage(Message message) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      selectedMessages.add(message);
    }
  }

  void cancelSelection() {
    selectedMessages.clear();
  }

  Future<void> deleteSelectedMessages() async {
    final confirmed = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Delete $numSelected messages?',
      subtitle:
          "Once you press delete, the messages will be gone forever. You won't be able to undo this action!",
    ));
    if (confirmed ?? false) {
      await _chatLogDb.deleteMessages(selectedMessages);
      // remove photos from list
      _chat.data.media.removeWhere(
        (m) => selectedMessages.any((message) => message.id == m.messageId),
      );
      await _commonChatDb.updateMediaList(_chat);
      // remove links from list
      for (int i = 0; i < _chat.data.links.length;) {
        final link = _chat.data.links[i];
        for (final message in selectedMessages) {
          if (link.messageId == message.id) {
            await _commonChatDb.removeLink(_chat, link);
            // this prevents concurrent modification error
            _chat.data.links.removeAt(i);
          } else {
            i++;
          }
        }
      }
      // firebase storage
      for (final message in selectedMessages) {
        if (message.photo != null) {
          await _storage.deletePhoto(message.photo!.url!);
        }
      }
      cancelSelection();
    }
  }

  void replyToSelectedMessages() {
    _messageSender.repliedMessage.value =
        selectedMessages.single.asRepliedMessage();
    cancelSelection();
  }

  void cancelMessageSelection() {
    cancelSelection();
  }
}
