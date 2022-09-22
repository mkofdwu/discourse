import 'package:discourse/models/db_objects/chat_member.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/chat/controllers/message_sender.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/models/replied_message.dart';
import 'package:discourse/services/media.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageDraftController extends GetxController {
  final _messageSender = Get.find<MessageSenderController>();
  final _media = Get.find<MediaService>();

  UserChat get _chat => Get.find<ChatController>().chat;
  TextEditingController get textController => _messageSender.textController;
  Rx<Photo?> get photoObs => _messageSender.photo;
  Rx<RepliedMessage?> get repliedMessageObs => _messageSender.repliedMessage;

  bool get hasText => !textController.text.isBlank!;
  bool get hasPhoto => _messageSender.photo.value != null;
  bool get hasRepliedMessage => _messageSender.repliedMessage.value != null;

  bool showAttachOptions = false;
  List<Member> pingOptions = [];

  @override
  void onReady() {
    textController.addListener(() {
      if (_chat is UserGroupChat) {
        final index = textController.text.lastIndexOf('@');
        if (index != -1) {
          final query = textController.text.substring(index).toLowerCase();
          pingOptions = _chat.groupData.members
              .where((member) =>
                  member.user.username.toLowerCase().contains(query))
              .toList();
        }
      }
      update();
    });
  }

  void toggleShowAttachOptions() {
    showAttachOptions = !showAttachOptions;
    update();
  }

  Future<void> selectPhoto(bool fromCamera) async {
    final newPhoto = await (fromCamera
        ? _media.takePhotoFromCamera()
        : _media.selectPhoto());
    if (newPhoto != null) {
      _messageSender.photo.value = newPhoto;
      showAttachOptions = false;
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

  void sendMessage() {
    _messageSender.send(_chat);
  }
}
