import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/services/relationships.dart';
import 'package:discourse/views/user_profile/user_profile_controller.dart';
import 'package:discourse/widgets/app_bar.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/story_border_painter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileView extends StatelessWidget {
  final DiscourseUser user;

  const UserProfileView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileController>(
      global: false,
      init: UserProfileController(user),
      builder: (controller) => Scaffold(
        appBar: myAppBar(
          title: 'User profile',
          actions: {
            FluentIcons.chat_24_regular: controller.sendMessage,
            FluentIcons.more_vertical_24_regular: controller.showProfileOptions,
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPaint(
                painter: StoryBorderPainter(
                  seenNum: controller.storySeenNum,
                  storyNum: controller.userStory?.length ?? 0,
                  animationValue: controller.storyBorderScale,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: PhotoOrIcon(
                    size: 100,
                    iconSize: 48,
                    photoUrl: user.photoUrl,
                    placeholderIcon: FluentIcons.person_48_regular,
                    hero: true,
                  ),
                ),
              ),
              SizedBox(height: 36),
              Row(
                children: [
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: 16),
                  if (controller.relationship == RelationshipStatus.friend)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'FRIEND',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
              if (user.aboutMe != null)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    user.aboutMe!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SizedBox(height: 60),
              if (controller.mediaUrls.isNotEmpty) ...[
                Text(
                  'Photos & videos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 5 / 6,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: controller.mediaUrls
                      .map((photoUrl) => OpacityFeedback(
                            onPressed: () =>
                                controller.toExaminePhoto(photoUrl),
                            child: Hero(
                              tag: photoUrl,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: photoUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
