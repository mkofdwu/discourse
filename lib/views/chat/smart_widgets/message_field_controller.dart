import 'package:discourse/models/replied_message.dart';
import 'package:discourse/models/unsent_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/chat/message_sender_service.dart';

class MessageFieldController extends GetxController {
  final _mediaService = Get.find<MediaService>();
  final _messageSenderService = Get.find<MessageSenderService>();

  TextEditingController get textController =>
      _messageSenderService.textController;
  Photo? get photo => _messageSenderService.photo;
  RepliedMessage? get repliedMessage => _messageSenderService.repliedMessage;
  List<UnsentMessage> get unsentMessages =>
      _messageSenderService.unsentMessages;

  bool get hasText => textController.text.isNotEmpty;
  bool get hasPhoto => photo != null;
  bool get hasRepliedMessage => repliedMessage != null;

  @override
  void onReady() {
    textController.addListener(() => update());
  }

  Future<void> selectPhoto() async {
    _messageSenderService.photo = await _mediaService.selectPhoto();
    update();
  }

  Future<void> takePhotoFromCamera() async {
    _messageSenderService.photo = await _mediaService.takePhotoFromCamera();
    update();
  }

  Future<void> sendMessage() => _messageSenderService.send();
}
