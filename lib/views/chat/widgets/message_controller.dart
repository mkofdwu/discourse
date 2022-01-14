import 'package:discourse/controllers/message_selection.dart';
import 'package:discourse/controllers/message_sender.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/views/examine_photo/examine_photo_view.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  final _messageSenderService = Get.find<MessageSenderController>();
  final _messageSelectionService = Get.find<MessageSelectionController>();

  final Message _message;

  MessageController(this._message);

  bool isSelected() =>
      _messageSelectionService.selectedMessages.contains(_message);

  void onTap() {
    if (_messageSelectionService.isSelecting) {
      toggleSelectMessage();
    } else if (_message.photo != null) {
      // view photo
      Get.to(ExaminePhotoView(photo: _message.photo!));
    }
  }

  void replyToThis() {
    _messageSenderService.repliedMessage.value = _message.asRepliedMessage();
  }

  void toggleSelectMessage() {
    _messageSelectionService.toggleSelectMessage(_message);
    update();
  }
}
