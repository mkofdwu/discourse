import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user.dart';

class Story {
  DiscourseUser user;
  List<StoryPage> pages;

  Story({required this.user, required this.pages});
}
