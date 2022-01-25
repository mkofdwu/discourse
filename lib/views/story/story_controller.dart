import 'package:discourse/models/db_objects/story_page.dart';
import 'package:get/get.dart';

class StoryController extends GetxController {
  final List<StoryPage> _story;

  StoryController(this._story);
}
