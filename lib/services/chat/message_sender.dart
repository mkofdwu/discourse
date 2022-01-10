import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/unsent_message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/chat/messages_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/storage.dart';

class MessageSenderController extends GetxController {
  final _auth = Get.find<AuthService>();
  final _messagesDb = Get.find<MessagesDbService>();
  final _privateChatDb = Get.find<PrivateChatDb>();
  final _storageService = Get.find<StorageService>();

  final textController = TextEditingController();
  Photo? photo;
  RepliedMessage? repliedMessage;
  final unsentMessages = <UnsentMessage>[];

  Future<void> send() async {
    final unsentMessage = UnsentMessage(
      chatId: _messagesDb.currentChat!.id,
      repliedMessage: repliedMessage,
      photo: photo,
      text: textController.text,
    );
    textController.text = '';
    photo = null;
    repliedMessage = null;
    unsentMessages.add(unsentMessage);
    update();

    if (_messagesDb.currentChat is NonExistentChat) {
      // chat hasn't been created yet
      if (unsentMessages.length == 1) {
        await _createChatThenSendUnsentMessages();
      } else {
        // do nothing, wait for chat to be created
      }
    } else {
      // send the message
      await _uploadMessagePhoto(unsentMessage);
      await _messagesDb.sendMessage(unsentMessage);
      unsentMessages.remove(unsentMessage);
      update();
    }
  }

  Future<void> _createChatThenSendUnsentMessages() async {
    await _privateChatDb.createChatWith(
        (_messagesDb.currentChat as NonExistentChat).data.otherUser);
    for (final unsent in List.from(unsentMessages)) {
      await _uploadMessagePhoto(unsent);
      await _messagesDb.sendMessage(unsent);
      unsentMessages.remove(unsent);
    }
    update();
  }

  Future<void> _uploadMessagePhoto(UnsentMessage message) async {
    if (message.photo != null && message.photo!.isLocal) {
      await _storageService.uploadPhoto(
        message.photo!,
        _auth.currentUser.id,
        'messagephoto',
      );
    }
  }
}
