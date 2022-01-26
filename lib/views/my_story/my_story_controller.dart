import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/views/my_story/new_photo_story/photo_edit_view.dart';
import 'package:discourse/views/my_story/new_text_story/new_text_story_view.dart';
import 'package:discourse/views/story/story_view.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:get/get.dart';

class MyStoryController extends GetxController {
  final _storyDb = Get.find<StoryDbService>();
  final _media = Get.find<MediaService>();

  Future<List<StoryPage>> getMyStory() => _storyDb.myStory();

  void viewMyStory() async {
    // TODO: store mystory in memory/in a getxservice?
    final myStory = await getMyStory();
    if (myStory.isEmpty) {
      Get.snackbar(
        'Nothing to show',
        'You dont have anything added to your story. Try writing something or adding a photo first',
      );
    } else {
      Get.to(StoryView(title: 'Your story', story: myStory));
    }
  }

  void viewSingleStory(StoryPage story) {
    Get.to(StoryView(title: 'Your story', story: [story]));
  }

  void deleteStory(StoryPage story) async {
    final confirm = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Delete story?',
      subtitle:
          'Are you sure you want to delete this story? This action is irreversible!',
    ));
    if (confirm ?? false) {
      await _storyDb.deleteStory(story.id);
      update();
    }
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
