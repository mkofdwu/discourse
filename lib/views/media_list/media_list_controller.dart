import 'package:discourse/models/photo.dart';
import 'package:discourse/views/examine_photo/examine_photo_view.dart';
import 'package:get/get.dart';

class MediaListController extends GetxController {
  void toExaminePhoto(String photoUrl) {
    Get.to(
      () => ExaminePhotoView(photo: Photo.url(photoUrl)),
      transition: Transition.fadeIn,
    );
  }
}
