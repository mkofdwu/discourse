import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/views/my_story/new_photo_story/photo_edit_view.dart';
import 'package:discourse/views/my_story/new_text_story/text_story_view.dart';
import 'package:discourse/views/story/story_view.dart';
import 'package:discourse/widgets/animated_list.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/models/unsent_story.dart';
import 'package:get/get.dart';

class MyStoryController extends GetxController {
  final _storyDb = Get.find<StoryDbService>();
  final _media = Get.find<MediaService>();
  final _storage = Get.find<StorageService>();
  final _relationships = Get.find<RelationshipsService>();

  final listAnimationController = ListAnimationController();
  List<StoryPage> myStory;

  MyStoryController(this.myStory);

  void viewMyStory() async {
    if (myStory.isEmpty) {
      Get.snackbar(
        'Nothing to show',
        'You dont have anything added to your story. Try writing something or adding a photo first',
      );
    } else {
      Get.to(() => StoryView(
            title: 'Your story',
            story: myStory,
            // TODO
            onShowOptions: () async {
              final choice = await Get.bottomSheet(ChoiceBottomSheet(
                title: 'Story options',
                choices: const ['Reply', 'Show viewed by'],
              ));
              if (choice == null) return;
            },
          ));
    }
  }

  void viewSingleStory(StoryPage story) {
    Get.to(() => StoryView(
          title: 'Your story',
          story: [story],
          // TODO
          onShowOptions: () async {
            final choice = await Get.bottomSheet(ChoiceBottomSheet(
              title: 'Story options',
              choices: const ['Reply', 'Show viewed by'],
            ));
            if (choice == null) return;
          },
        ));
  }

  void editStory(StoryPage story) async {
    if (story.type == StoryType.text) {
      await Get.to(() => TextStoryView(defaultStory: story));
    } else {
      final editedPhoto = await Get.to<Photo>(PhotoEditView(
        photo: Photo.url(story.content),
      ));
      if (editedPhoto == null) return;
      await _storage.deletePhoto(story.content); // old photo
      await _storage.uploadPhoto(editedPhoto, 'storyphoto');
      await _storyDb.updateStory(story.id, editedPhoto.url);
    }
    update();
  }

  void deleteStory(int i) async {
    final story = myStory.removeAt(i);
    final confirm = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Delete story?',
      subtitle:
          'Are you sure you want to delete this story? This action is irreversible!',
    ));
    if (confirm ?? false) {
      await _storyDb.deleteStory(story.id);
      listAnimationController.animateRemove(i, story);
      update();
    }
  }

  void newTextPost() async {
    final result = await Get.to(() => TextStoryView());
    if (result != null) {
      myStory.add(result as StoryPage);
      if (myStory.length > 1) {
        // if story was empty at first, list hasn't been created yet
        listAnimationController.animateInsert(myStory.length - 1);
      }
    }
    update();
  }

  void newPhotoPost() async {
    final photo = await _media.selectPhoto();
    if (photo != null) {
      final editedPhoto = await Get.to<Photo>(PhotoEditView(photo: photo));
      if (editedPhoto == null) return;
      await _storage.uploadPhoto(editedPhoto, 'storyphoto');
      final story = await _storyDb.postStory(UnsentStory(
        type: StoryType.photo,
        content: editedPhoto.url!,
        sendToIds: await _relationships
            .getFriends(), // future: select friend list before posting photo
      ));
      myStory.add(story);
      listAnimationController.animateInsert(myStory.length - 1);
      update();
    }
  }
}
