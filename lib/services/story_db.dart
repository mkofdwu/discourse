import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/services/auth.dart';
import 'package:get/get.dart';

abstract class BaseStoryDbService {
  Future<List<StoryPage>> myStory();
  Future<List<StoryPage>> getUserStory(String userId);
  Future<void> postStory(StoryPage story, List<String> sendTo);
}

class StoryDbService extends GetxService implements BaseStoryDbService {
  final _auth = Get.find<AuthService>();

  final _usersRef = FirebaseFirestore.instance.collection('users');

  @override
  Future<List<StoryPage>> getUserStory(String userId) {
    // TODO: implement getUserStory
    throw UnimplementedError();
  }

  @override
  Future<List<StoryPage>> myStory() {
    // TODO: implement myStory
    throw UnimplementedError();
  }

  @override
  Future<void> postStory(StoryPage story, List<String> sendTo) async {
    await _usersRef.doc(_auth.id).collection('story').add(story.toData());
  }
}
