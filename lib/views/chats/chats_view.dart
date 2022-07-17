import 'package:cached_network_image/cached_network_image.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/views/chats/onboarding_view.dart';
import 'package:discourse/widgets/floating_action_button.dart';
import 'package:discourse/widgets/icon_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo_or_icon.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/widgets/story_border_painter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:discourse/views/chats/chats_controller.dart';

class ChatsView extends StatelessWidget {
  const ChatsView({Key? key}) : super(key: key);

  ChatsController get controller => Get.find<ChatsController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatsController>(
      init: ChatsController(),
      builder: (controller) => Scaffold(
        floatingActionButton: controller.hasNoContent
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 12, right: 10),
                child: MyFloatingActionButton(
                  iconData: FluentIcons.people_community_add_20_regular,
                  onPressed: controller.newGroup,
                ),
              ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: _buildTop(),
              ),
              SizedBox(height: 36),
              if (controller.isLoading)
                Center(child: CircularProgressIndicator(strokeWidth: 2))
              else if (controller.hasNoContent)
                OnboardingView()
              else
                ..._buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Good ${timeOfDay()}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          MyIconButton(
            FluentIcons.alert_24_regular,
            onPressed: controller.toActivity,
            child: Stack(
              children: [
                Icon(FluentIcons.alert_24_regular),
                !controller.hasNewRequests
                    ? SizedBox.shrink()
                    : Positioned(
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
                      ),
              ],
            ),
          ),
        ],
      );

  List<Widget> _buildContent() => [
        // announcement
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 36),
        //   child: _buildAnnouncement(),
        // ),
        // SizedBox(height: 36),
        //
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stories',
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                FluentIcons.chevron_down_20_filled,
                size: 20,
                color: Colors.white.withOpacity(0.4),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildStories(),
        SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chats',
                style: TextStyle(
                  color: Get.theme.primaryColor.withOpacity(0.4),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                FluentIcons.chevron_down_20_filled,
                size: 20,
                color: Colors.white.withOpacity(0.4),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: _buildChatsList(),
        ),
      ];

  Widget _buildAnnouncement() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: Palette.black3,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              FluentIcons.info_28_regular,
              color: Palette.orange,
              size: 28,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vestibulum, cras',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Morbi id donec aliquet elit. Volutpat morbi egestas accumsan, non.',
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );

  Widget _buildStories() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 40),
            _buildYourStoryButton(),
            SizedBox(width: 20),
            if (controller.friendsStories.isNotEmpty)
              Row(
                children: controller.friendsStories.entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: OpacityFeedback(
                            onPressed: () =>
                                controller.viewStory(entry.key, entry.value),
                            child: Column(
                              children: [
                                CustomPaint(
                                  painter: StoryBorderPainter(
                                    seenNum: controller.seenNum(entry.value),
                                    storyNum: entry.value.length,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                          entry.key.photoUrl != null
                                              ? CachedNetworkImageProvider(
                                                  entry.key.photoUrl!)
                                              : null,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  entry.key.username,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            SizedBox(width: 40),
          ],
        ),
      );

  Widget _buildYourStoryButton() => PressedBuilder(
        onPressed: controller.toMyStory,
        builder: (pressed) => Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Palette.orange, width: 3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: PhotoOrIcon(
                      photoUrl: controller.currentUser.photoUrl,
                      placeholderIcon: FluentIcons.person_28_regular,
                      size: 80,
                      iconSize: 28,
                    ),
                  ),
                ),
                if (controller.numMyStories == 0)
                  SizedBox.shrink()
                else
                  Positioned(
                    right: 0,
                    top: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Palette.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          controller.numMyStories.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Your story',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _buildChatsList() => controller.chats.isEmpty
      ? SizedBox.shrink()
      : Column(
          children: controller.chats
              .map((chat) => StreamBuilder<ChatLogObject>(
                    stream: controller.streamLastChatObject(chat),
                    builder: (context, snapshot) {
                      String? subtitle;
                      if (snapshot.hasData) {
                        final chatObject = snapshot.data!;
                        // TODO: show icon next to text (e.g. photo or chat action icon)
                        if (chatObject is Message) {
                          subtitle = chatObject.fromMe
                              ? 'You: ${chatObject.reprContent}'
                              : chatObject.reprContent;
                        } else {
                          subtitle = chatObject.asChatAlert.content;
                        }
                      }
                      return StreamBuilder<int>(
                          stream: controller.numUnreadMessagesStream(chat),
                          builder: (context, snapshot) {
                            return MyListTile(
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
                            );
                          });
                    },
                  ))
              .toList(),
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
