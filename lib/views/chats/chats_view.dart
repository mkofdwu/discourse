import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/widgets/list_tile.dart';
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
      init: ChatsController(),
      builder: (controller) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Good evening',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  // TODO: show if has new activity
                  Icon(FluentIcons.alert_24_regular),
                ],
              ),
              SizedBox(height: 36),
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
                'Friends',
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              _buildChatsList(),
            ],
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
                backgroundColor: Colors.red,
                backgroundImage: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1641644453400-6b64aef39cdf?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80'),
              ),
            ),
          ),
        ],
      );

  Widget _buildChatsList() => Column(
        children: [
          MyListTile(
            title: 'Mr Tree',
            subtitle: 'The quick brown fox jumps over the lazy dog',
            photoUrl:
                'https://images.unsplash.com/photo-1641579281152-e5d633aa3775?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1632&q=80',
            iconData: FluentIcons.person_16_regular,
            suffixIcons: {
              FluentIcons.more_vertical_20_regular: () {},
            },
            onPressed: () {},
          ),
        ],
      );
}
