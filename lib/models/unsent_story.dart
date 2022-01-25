import 'package:discourse/models/db_objects/story_page.dart';

class UnsentStory {
  StoryType type;
  dynamic content; // text or photoUrl
  List<String> sendToIds;

  UnsentStory({
    required this.type,
    required this.content,
    required this.sendToIds,
  });
}
