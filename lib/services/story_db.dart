import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/friend_list.dart';
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
  Future<Map<DiscourseUser, List<StoryPage>>> friendsStories();
  Future<void> postStory(UnsentStory story);
  Future<void> deleteStory(String storyId);
  Future<void> updateStory(String storyId, dynamic newContent);
  Future<List<FriendList>> myFriendLists();
  Future<FriendList> newFriendList(String name, List<DiscourseUser> friends);
  Future<void> updateFriendList(FriendList friendList);
  Future<void> deleteFriendList(String id);
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

  @override
  Future<Map<DiscourseUser, List<StoryPage>>> friendsStories() async {
    final friendIds = await _relationships.getFriends();
    final stories = <DiscourseUser, List<StoryPage>>{};
    for (final userId in friendIds) {
      final story = await getUserStory(userId);
      if (story.isNotEmpty) {
        stories[await _userDb.getUser(userId)] = story;
      }
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

  @override
  Future<void> deleteStory(String storyId) async {
    await _usersRef.doc(_auth.id).collection('story').doc(storyId).delete();
  }

  @override
  Future<void> updateStory(String storyId, dynamic newContent) async {
    await _usersRef.doc(_auth.id).collection('story').doc(storyId).update({
      'content': newContent,
      'editedTimestamp': DateTime.now(),
    });
  }

  @override
  Future<List<FriendList>> myFriendLists() async {
    final snapshot =
        await _usersRef.doc(_auth.id).collection('friendLists').get();
    final friendLists = <FriendList>[];
    for (final doc in snapshot.docs) {
      final friendIds = List<String>.from(doc.data()['friendIds']);
      final friends =
          await Future.wait(friendIds.map((id) => _userDb.getUser(id)));
      friendLists.add(FriendList.fromDoc(doc, friends));
    }
    return friendLists;
  }

  @override
  Future<FriendList> newFriendList(
      String name, List<DiscourseUser> friends) async {
    final ref = await _usersRef.doc(_auth.id).collection('friendLists').add({
      'name': name,
      'friendIds': friends.map((user) => user.id).toList(),
    });
    return FriendList(id: ref.id, name: name, friends: friends);
  }

  @override
  Future<void> updateFriendList(FriendList friendList) async {
    // FIXME: like the method for updating documents in other services,
    // this could be optimized
    await _usersRef
        .doc(_auth.id)
        .collection('friendLists')
        .doc(friendList.id)
        .update(friendList.toData());
  }

  @override
  Future<void> deleteFriendList(String id) async {
    await _usersRef.doc(_auth.id).collection('friendLists').doc(id).delete();
  }
}
