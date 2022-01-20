import 'package:discourse/views/chat/controllers/message_sender.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/services/media.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageDraftController extends GetxController {
  final _currentChat = Get.find<UserChat>();
  final _messageSender = Get.find<MessageSenderController>();
  final _media = Get.find<MediaService>();

  TextEditingController get textController => _messageSender.textController;
  Photo? get photo => _messageSender.photo.value;
  RepliedMessage? get repliedMessage => _messageSender.repliedMessage.value;

  bool get hasText => !textController.text.isBlank!;
  bool get hasPhoto => photo != null;
  bool get hasRepliedMessage => repliedMessage != null;

  bool showAttachOptions = false;

  @override
  void onReady() {
    textController.addListener(() => update());
  }

  void toggleShowAttachOptions() {
    showAttachOptions = !showAttachOptions;
    update();
  }

  Future<void> selectPhoto(bool fromCamera) async {
    final photo = await (fromCamera
        ? _media.takePhotoFromCamera()
        : _media.selectPhoto());
    if (photo != null) {
      _messageSender.photo.value = photo;
      update();
    }
  }

  void removeReply() {
    _messageSender.repliedMessage.value = null;
    update();
  }

  void removePhoto() {
    _messageSender.photo.value = null;
    update();
  }

  sendMessage() => _messageSender.send(_currentChat);
}
