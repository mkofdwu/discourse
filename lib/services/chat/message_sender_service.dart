import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/unsent_message.dart';
import 'package:discourse/models/user_chat.dart';
import 'package:discourse/services/chat_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/storage.dart';

class MessageSenderService extends GetxController {
  // TODO: controller or service; how to update?
  final _chatDb = Get.find<ChatDbService>();
  final _storageService = Get.find<StorageService>();

  final textController = TextEditingController();
  Photo? photo;
  RepliedMessage? repliedMessage;
  final unsentMessages = <UnsentMessage>[];

  Future<void> send() async {
    final unsentMessage = UnsentMessage(
      chatId: _chatDb.currentChat!.id,
      repliedMessage: repliedMessage,
      photo: photo,
      text: textController.text,
    );
    textController.text = '';
    photo = null;
    repliedMessage = null;
    unsentMessages.add(unsentMessage);
    // _userChat.data.lastMessageText = message.text; NOT WORKING
    update();

    if (_chatDb.currentChat is NonExistentChat) {
      // chat hasn't been created yet
      if (unsentMessages.length == 1) {
        await _createChatThenSendUnsentMessages();
      } else {
        // do nothing, wait for chat to be created
      }
    } else {
      // send the message
      await _uploadMessagePhoto(unsentMessage);
      await _chatDb.sendMessage(unsentMessage);
      unsentMessages.remove(unsentMessage);
      update();
    }
  }

  Future<void> _createChatThenSendUnsentMessages() async {
    await _chatDb
        .createChatWith((_chatDb.currentChat as NonExistentChat).otherUser);
    for (final unsent in List.from(unsentMessages)) {
      await _uploadMessagePhoto(unsent);
      await _chatDb.sendMessage(unsent);
      unsentMessages.remove(unsent);
    }
    update();
  }

  Future<void> _uploadMessagePhoto(UnsentMessage message) async {
    if (message.photo != null && message.photo!.isLocal) {
      await _storageService.uploadPhoto(message.photo!, 'messagephoto');
    }
  }
}
