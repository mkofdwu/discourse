import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/unsent_message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/services/chat/common_chat_db.dart';
import 'package:discourse/services/chat/group_chat_db.dart';
import 'package:discourse/services/chat/chat_log_db.dart';
import 'package:discourse/services/chat/private_chat_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/storage.dart';

class MessageSenderController extends GetxController {
  final _chatLogDb = Get.find<ChatLogDbService>();
  final _privateChatDb = Get.find<PrivateChatDbService>();
  final _groupChatDb = Get.find<GroupChatDbService>();
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
      // send the message
      await _uploadMessagePhoto(unsentMessage, chat);
      await _chatLogDb.sendMessage(unsentMessage);
      unsentMessages.remove(unsentMessage);
      update();
    }
  }

  Future<void> _createChatThenSendUnsentMessages(NonExistentChat chat) async {
    final privateChat = await _privateChatDb.createChatWith(chat.otherUser);
    for (UnsentMessage unsent in List.from(unsentMessages)) {
      unsent.chatId = privateChat.id;
      await _uploadMessagePhoto(unsent, privateChat);
      await _chatLogDb.sendMessage(unsent);
      unsentMessages.remove(unsent);
    }
    Get.put<UserChat>(privateChat);
    update();
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
