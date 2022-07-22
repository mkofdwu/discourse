import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/views/story/story_view.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/story_border_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserStoryTile extends StatelessWidget {
  final DiscourseUser user;
  final List<StoryPage> story;
  final int seenNum;

  const UserStoryTile({
    Key? key,
    required this.user,
    required this.story,
    required this.seenNum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpacityFeedback(
      onPressed: _viewStory,
      child: Column(
        children: [
          CustomPaint(
            painter: StoryBorderPainter(
              seenNum: seenNum,
              storyNum: story.length,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: user.photoUrl != null
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            user.username,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _viewStory() {
    Get.to(StoryView(
      title: "${user.username}'s story",
      story: story,
      // TODO
      onShowOptions: () async {},
    ));
  }
}
