import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/story_page.dart';
import 'package:discourse/models/db_objects/user.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/widgets/floating_action_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/story_border_painter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/views/chats/chats_controller.dart';

class ChatsView extends StatelessWidget {
  const ChatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatsController>(
      global: false,
      init: ChatsController(),
      builder: (controller) => Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 10),
          child: MyFloatingActionButton(
            iconData: FluentIcons.people_community_add_20_regular,
            onPressed: controller.newGroup,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Good evening',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  OpacityFeedback(
                    child: Stack(
                      children: [
                        Icon(FluentIcons.alert_24_regular),
                        FutureBuilder<bool>(
                          future: controller.hasNewRequests(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !snapshot.data!) {
                              return SizedBox.shrink();
                            }
                            return Positioned(
                              top: 0,
                              right: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Palette.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onPressed: controller.toActivity,
                  ),
                ],
              ),
              SizedBox(height: 40),
              // announcement
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                  decoration: BoxDecoration(
                    color: Palette.black3,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        FluentIcons.info_24_regular,
                        color: Palette.orange,
                        size: 24,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vestibulum, cras',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Morbi id donec aliquet elit. Volutpat morbi egestas accumsan, non.',
                              style: TextStyle(
                                color: Get.theme.primaryColor.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
              SizedBox(height: 36),
              //
              Text(
                'Stories',
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              _buildStories(controller),
              SizedBox(height: 40),
              Text(
                'Chats',
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              _buildChatsList(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStories(ChatsController controller) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildYourStoryButton(controller),
            SizedBox(width: 28),
            FutureBuilder<Map<DiscourseUser, List<StoryPage>>>(
              future: controller.getFriendsStories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                return Row(
                  children: snapshot.data!.entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(right: 28),
                            child: OpacityFeedback(
                              onPressed: () =>
                                  controller.viewStory(entry.key, entry.value),
                              child: CustomPaint(
                                painter: StoryBorderPainter(
                                  seenNum: controller.seenNum(entry.value),
                                  storyNum: entry.value.length,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundImage: entry.key.photoUrl != null
                                        ? CachedNetworkImageProvider(
                                            entry.key.photoUrl!)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      );

  Widget _buildYourStoryButton(ChatsController controller) => PressedBuilder(
        onPressed: controller.toMyStory,
        builder: (pressed) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Get.theme.primaryColor.withOpacity(pressed ? 0.2 : 0.1),
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(FluentIcons.image_24_regular, size: 24),
                      SizedBox(height: 8),
                      Text('Your story', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              FutureBuilder<int>(
                future: controller.numMyStories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == 0) {
                    return SizedBox.shrink();
                  }
                  return Positioned(
                    right: 0,
                    top: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          snapshot.data.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildChatsList(ChatsController controller) =>
      FutureBuilder<List<UserChat>>(
        future: controller.getChats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }
          return Column(
            children: snapshot.data!
                .map((chat) => StreamBuilder(
                      stream: controller.lastMessageStream(chat),
                      builder: (context, AsyncSnapshot<Message?> snapshot) {
                        String subtitle = '';
                        if (snapshot.hasData) {
                          final message = snapshot.data!;
                          // all these are private chats, if from other person dont repeat username
                          subtitle = message.fromMe
                              ? 'You: ${message.reprContent}'
                              : message.reprContent;
                        }
                        return StreamBuilder<int>(
                            stream: controller.numUnreadMessagesStream(chat),
                            builder: (context, snapshot) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: MyListTile(
                                  title: chat.title,
                                  subtitle: subtitle,
                                  photoUrl: chat.photoUrl,
                                  iconData: FluentIcons.person_16_regular,
                                  extraWidgets: [
                                    if (snapshot.hasData && snapshot.data! > 0)
                                      _buildNumUnreadMessages(snapshot.data!)
                                  ],
                                  suffixIcons: {
                                    if (chat.pinned)
                                      FluentIcons.pin_16_filled: () =>
                                          controller.togglePinChat(chat),
                                    FluentIcons.more_vertical_20_regular: () =>
                                        controller.showChatOptions(chat),
                                  },
                                  onPressed: () => controller.toChat(chat),
                                ),
                              );
                            });
                      },
                    ))
                .toList(),
          );
        },
      );

  Widget _buildNumUnreadMessages(int numUnreadMessages) => Container(
        height: 16,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Palette.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            numUnreadMessages.toString(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
