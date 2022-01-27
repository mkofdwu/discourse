import 'package:discourse/models/db_objects/friend_list.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/photo.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/storage.dart';
import 'package:discourse/models/unsent_story.dart';
import 'package:discourse/services/story_db.dart';
import 'package:get/get.dart';

class NewPhotoStoryController extends GetxController {
  final _storage = Get.find<StorageService>();
  final _storyDb = Get.find<StoryDbService>();
  final _relationships = Get.find<RelationshipsService>();

  final Photo _photo;
  FriendList? selectedFriendList; // if null, send to all friends

  NewPhotoStoryController(this._photo);

  void submit() async {
    await _storage.uploadPhoto(_photo, 'storyphoto');
    await _storyDb.postStory(UnsentStory(
      type: StoryType.photo,
      content: _photo.url!,
      sendToIds: selectedFriendList == null
          ? await _relationships.getFriends()
          : selectedFriendList!.friends.map((user) => user.id).toList(),
    ));
    Get.back();
  }
}
