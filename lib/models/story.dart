import 'package:discourse/models/story_page.dart';
import 'package:discourse/models/user.dart';

class Story {
  DiscourseUser user;
  List<StoryPage> pages;

  Story({required this.user, required this.pages});
}
