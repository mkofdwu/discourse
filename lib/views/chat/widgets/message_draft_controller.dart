import 'package:discourse/controllers/message_sender.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageDraftController extends GetxController {
  final _currentChat = Get.find<UserChat>();
  final _messageSender = Get.find<MessageSenderController>();

  TextEditingController get textController => _messageSender.textController;

  bool showAttachOptions = false;

  @override
  void onReady() {
    textController.addListener(() => update());
  }

  void toggleShowAttachOptions() {
    showAttachOptions = !showAttachOptions;
    update();
  }

  sendMessage() => _messageSender.send(_currentChat);
}
