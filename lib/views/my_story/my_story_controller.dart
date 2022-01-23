import 'package:discourse/views/my_story/new_text_story/new_text_story_view.dart';
import 'package:get/get.dart';

class MyStoryController extends GetxController {
  void newTextPost() {
    Get.to(NewTextStoryView());
  }

  void newPhotoPost() {}
}
