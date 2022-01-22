import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/widgets/floating_action_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
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
        floatingActionButton: MyFloatingActionButton(
          iconData: FluentIcons.add_20_filled,
          onPressed: controller.newChat,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Good evening',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
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
                      onPressed: controller.goToActivity,
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Text(
                  'Stories',
                  style: TextStyle(
                    color: Get.theme.primaryColor.withOpacity(0.4),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20),
                _buildStories(),
                SizedBox(height: 40),
                Text(
                  'Private chats',
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
      ),
    );
  }

  Widget _buildStories() => Row(
        children: [
          CustomPaint(
            painter: StoryBorderPainter(seenNum: 3, storyNum: 5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1641644453400-6b64aef39cdf?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80'),
              ),
            ),
          ),
        ],
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: MyListTile(
                            title: chat.title,
                            subtitle: subtitle,
                            photoUrl: chat.photoUrl,
                            iconData: FluentIcons.person_16_regular,
                            suffixIcons: {
                              if (chat.pinned)
                                FluentIcons.pin_16_filled: () =>
                                    controller.togglePinChat(chat),
                              FluentIcons.more_vertical_20_regular: () =>
                                  controller.showChatOptions(chat),
                            },
                            onPressed: () => controller.goToChat(chat),
                          ),
                        );
                      },
                    ))
                .toList(),
          );
        },
      );
}
