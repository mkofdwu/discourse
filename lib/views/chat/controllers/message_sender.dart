import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/unsent_message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/chat_log_str.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/chat/controllers/message_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/storage.dart';

class MessageSenderController extends GetxController {
  final _chatLogDb = Get.find<ChatLogDbService>();
  final _chatLogStr = Get.find<ChatLogStrService>();
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _commonChatDb = Get.find<CommonChatDbService>();
  final _storage = Get.find<StorageService>();

  final textController = TextEditingController();
  final photo = Rx<Photo?>(null);
  final repliedMessage = Rx<RepliedMessage?>(null);
  final unsentMessages = <UnsentMessage>[].obs;

  Future<void> send(UserChat chat) async {
    final unsentMessage = UnsentMessage(
      chatId: chat.id,
      repliedMessage: repliedMessage.value,
      photo: photo.value,
      text: textController.text.trim(),
    );
    textController.text = '';
    photo.value = null;
    repliedMessage.value = null;
    unsentMessages.add(unsentMessage);
    update();

    if (chat is NonExistentChat) {
      // chat hasn't been created yet
      if (unsentMessages.length == 1) {
        await _createChatThenSendUnsentMessages(chat);
      } else {
        // do nothing, wait for chat to be created
      }
    } else {
      _actuallySendMessage(unsentMessage, chat);
      update();
    }
  }

  Future<void> _actuallySendMessage(
      UnsentMessage unsentMessage, UserChat chat) async {
    await _uploadMessagePhoto(unsentMessage, chat);
    final message = await _chatLogDb.sendMessage(unsentMessage);
    // await _chatLogStr.appendToLog(message);
    unsentMessages.remove(unsentMessage);
  }

  Future<void> _createChatThenSendUnsentMessages(NonExistentChat chat) async {
    final privateChat = await _privateChatDb.createChatWith(chat.otherUser);
    for (UnsentMessage unsent in List.from(unsentMessages)) {
      unsent.chatId = privateChat.id;
      _actuallySendMessage(unsent, privateChat);
    }
    Get.find<ChatController>().chat = privateChat;
    Get.find<MessageListController>().watchLastMessage();
    Get.find<ChatController>().update();
  }

  Future<void> _uploadMessagePhoto(UnsentMessage message, UserChat chat) async {
    if (message.photo != null && message.photo!.isLocal) {
      await _storage.uploadPhoto(message.photo!, 'messagephoto');
    }
    if (message.photo != null) {
      await _commonChatDb.addMediaUrl(chat, message.photo!.url!);
      chat.data.mediaUrls.add(message.photo!.url!);
      update();
    }
  }
}
