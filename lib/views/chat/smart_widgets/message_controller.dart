import 'package:discourse/views/examine_photo/examine_photo_view.dart';
import 'package:get/get.dart';
import 'package:discourse/models/message.dart';
import 'package:discourse/services/chat/message_sender_service.dart';
import 'package:discourse/services/chat/message_selection_service.dart';

class MessageController extends GetxController {
  final _messageSenderService = Get.find<MessageSenderService>();
  final _messageSelectionService = Get.find<MessageSelectionService>();

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
    _messageSenderService.repliedMessage = _message.asRepliedMessage();
  }

  void toggleSelectMessage() {
    _messageSelectionService.toggleSelectMessage(_message);
    update();
  }
}
