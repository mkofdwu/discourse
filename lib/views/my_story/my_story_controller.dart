import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/views/my_story/new_photo_story/photo_edit_view.dart';
import 'package:discourse/views/my_story/new_text_story/new_text_story_view.dart';
import 'package:discourse/views/story/story_view.dart';
import 'package:get/get.dart';

class MyStoryController extends GetxController {
  final _storyDb = Get.find<StoryDbService>();
  final _media = Get.find<MediaService>();

  Future<List<StoryPage>> getMyStory() => _storyDb.myStory();

  void viewMyStory() async {
    Get.to(StoryView(title: 'Your story', story: await getMyStory()));
  }

  void viewSingleStory(StoryPage story) {
    Get.to(StoryView(title: 'Your story', story: [story]));
  }

  void newTextPost() async {
    await Get.to(NewTextStoryView());
    update();
  }

  void newPhotoPost() async {
    final photo = await _media.selectPhoto();
    if (photo != null) {
      await Get.to(NewPhotoStoryView(photo: photo));
      update();
    }
  }
}
