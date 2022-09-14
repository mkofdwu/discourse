import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/media.dart';
import 'package:discourse/services/misc_cache.dart';
import 'package:discourse/services/story_db.dart';
import 'package:discourse/services/user_db.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/views/my_story/new_photo_story/photo_edit_view.dart';
import 'package:discourse/views/my_story/new_text_story/text_story_view.dart';
import 'package:discourse/views/story/story_view.dart';
import 'package:discourse/widgets/animated_list.dart';
import 'package:discourse/widgets/bottom_sheets/choice_bottom_sheet.dart';
import 'package:discourse/widgets/bottom_sheets/yesno_bottom_sheet.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/models/unsent_story.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/snack_bar.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// used for bottom sheet
double lerp(double from, double to, double extent, double startAfter) {
  if (extent < startAfter) return from;
  return from + (to - from) * (extent - startAfter) / (1 - startAfter);
}

class MyStoryController extends GetxController {
  final _storyDb = Get.find<StoryDbService>();
  final _media = Get.find<MediaService>();
  final _storage = Get.find<StorageService>();
  final _relationships = Get.find<RelationshipsService>();
  final _userDb = Get.find<UserDbService>();

  final listAnimationController = ListAnimationController();
  final selectedStories = RxList<StoryPage>();

  RxList<StoryPage> get myStory => Get.find<MiscCache>().myStory;
  bool get isSelecting => selectedStories.isNotEmpty;

  MyStoryController();

  void viewMyStory() async {
    if (myStory.isEmpty) {
      showSnackBar(
        type: SnackBarType.info,
        message: 'Try adding a story first!',
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

  void onTapStory(StoryPage story) {
    if (isSelecting) {
      toggleSelectStory(story);
    } else {
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
  }

  void editSelectedStory() async {
    assert(selectedStories.length == 1);
    final story = selectedStories.removeAt(0);
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

  void deleteSelectedStories() async {
    final confirm = await Get.bottomSheet(YesNoBottomSheet(
      title: 'Delete stories?',
      subtitle:
          'Are you sure you want to delete ${selectedStories.length} stories? This action is irreversible!',
    ));
    if (confirm ?? false) {
      for (final story in selectedStories) {
        final index = myStory.indexOf(story);
        await _storyDb.deleteStory(story.id);
        listAnimationController.animateRemove(index, story);
        myStory.removeAt(index);
      }
      selectedStories.clear();
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
    }
  }

  void showViewedBy() async {
    assert(selectedStories.length == 1);
    final story = selectedStories.removeAt(0);
    final viewedAt = <DiscourseUser, DateTime>{};
    for (final entry in story.viewedAt.entries) {
      final user = await _userDb.getUser(entry.key);
      viewedAt[user] = entry.value;
    }
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: viewedAt.isEmpty ? 0.6 : 1,
          builder: (context, controller) {
            return LayoutBuilder(builder: (context, constraints) {
              final progress = constraints.maxHeight / Get.height;
              return Container(
                margin:
                    EdgeInsets.symmetric(horizontal: lerp(8, 0, progress, 0.8)),
                decoration: BoxDecoration(
                  color: Get.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(lerp(10, 0, progress, 0.86)),
                    topRight: Radius.circular(lerp(10, 0, progress, 0.86)),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
                  child: Column(
                    children: [
                      Text(
                        'Viewed by',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 30),
                      if (viewedAt.isEmpty) ...[
                        SizedBox(height: 30),
                        Image.asset(
                          'assets/images/undraw_book.png',
                          width: 160,
                        ),
                        SizedBox(height: 40),
                        Text(
                          'No one has seen your story yet',
                          style: TextStyle(
                            color: Get.theme.primaryColor.withOpacity(0.6),
                          ),
                        ),
                      ] else
                        ...viewedAt
                            .map((user, timestamp) => MapEntry(
                                user,
                                MyListTile(
                                  title: user.username,
                                  // removed after 24 hours so its either today or ystd
                                  subtitle: timeTodayOrYesterday(timestamp),
                                  photoUrl: story.type == StoryType.photo
                                      ? story.content
                                      : null,
                                  iconData:
                                      FluentIcons.text_description_24_regular,
                                )))
                            .values,
                    ],
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void toggleSelectStory(StoryPage story) {
    if (selectedStories.contains(story)) {
      selectedStories.remove(story);
    } else {
      selectedStories.add(story);
    }
  }

  void cancelSelection() {
    selectedStories.clear();
  }
}
