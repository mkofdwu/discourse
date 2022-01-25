import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/unsent_story.dart';
import 'package:discourse/services/auth.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/services/user_db.dart';
import 'package:get/get.dart';

abstract class BaseStoryDbService {
  Future<List<StoryPage>> myStory();
  Future<List<StoryPage>> getUserStory(String userId);
  Future<void> postStory(UnsentStory story);
}

class StoryDbService extends GetxService implements BaseStoryDbService {
  final _auth = Get.find<AuthService>();
  final _relationships = Get.find<RelationshipsService>();
  final _userDb = Get.find<UserDbService>();

  final _usersRef = FirebaseFirestore.instance.collection('users');

  @override
  Future<List<StoryPage>> getUserStory(String userId) async {
    final snapshot = await _usersRef
        .doc(userId)
        .collection('story')
        .where('sentToIds', arrayContains: _auth.id)
        .get();
    return snapshot.docs.map((doc) => StoryPage.fromDoc(doc)).toList();
  }

  Future<Map<DiscourseUser, List<StoryPage>>> friendsStories() async {
    final friendIds = await _relationships.getFriends();
    final stories = <DiscourseUser, List<StoryPage>>{};
    for (final userId in friendIds) {
      stories[await _userDb.getUser(userId)] = await getUserStory(userId);
    }
    return stories;
  }

  @override
  Future<List<StoryPage>> myStory() async {
    final snapshot = await _usersRef
        .doc(_auth.id)
        .collection('story')
        .orderBy('sentTimestamp')
        .get();
    return snapshot.docs.map((doc) => StoryPage.fromDoc(doc)).toList();
  }

  @override
  Future<void> postStory(UnsentStory story) async {
    await _usersRef.doc(_auth.id).collection('story').add({
      'type': story.type.index,
      'content': story.content,
      'sentTimestamp': DateTime.now(),
      // 'editedTimestamp': null,
      'sentToIds': story.sendToIds,
      'viewedAt': {},
    });
  }
}
