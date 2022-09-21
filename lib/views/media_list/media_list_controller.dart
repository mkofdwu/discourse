import 'package:discourse/models/db_objects/message_media_url.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/views/chat/controllers/message_list.dart';
import 'package:discourse/views/chat/chat_controller.dart';
import 'package:discourse/views/examine_photo/examine_photo_view.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';

class MediaListController extends GetxController {
  void toExaminePhoto(MessageMedia media) {
    Get.to(
      () => ExaminePhotoView(
        photo: Photo.url(media.photoUrl),
        suffixIcons: {
          FluentIcons.arrow_circle_right_24_regular: () {
            Get.back();
            Get.back();
            Get.back();
            Get.find<MessageListController>().scrollToMessage(media.messageId);
            Get.find<ChatController>().highlightMessage(media.messageId);
          },
        },
      ),
      transition: Transition.fadeIn,
    );
  }
}
