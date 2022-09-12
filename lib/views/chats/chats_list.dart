import 'package:discourse/models/chat_log_object.dart';
import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/utils/date_time.dart';
import 'package:discourse/views/chats/chats_controller.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatsList extends StatelessWidget {
  ChatsController get controller => Get.find();

  const ChatsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: controller.chats
          .map((chat) => StreamBuilder<ChatLogObject>(
                stream: controller.streamLastChatObject(chat),
                builder: (context, snapshot) {
                  String? subtitle;
                  String lastActive = '';
                  if (snapshot.hasData) {
                    final chatObject = snapshot.data!;
                    if (chatObject is Message) {
                      subtitle = chatObject.fromMe
                          ? 'You: ${chatObject.reprContent}'
                          : chatObject.reprContent;
                    } else {
                      subtitle = chatObject.asChatAlert.content;
                    }
                    lastActive = formatTimeAgo(chatObject.sentTimestamp);
                  }
                  return StreamBuilder<int>(
                    stream: controller.numUnreadMessagesStream(chat),
                    builder: (context, snapshot) {
                      final numUnreadMessages = snapshot.data ?? 0;
                      return Obx(
                        () => MyListTile(
                          isSelected: controller.selectedChats.contains(chat),
                          title: chat.title,
                          subtitle: subtitle,
                          photoUrl: chat.photoUrl,
                          iconData: FluentIcons.person_16_regular,
                          extraWidgets: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  lastActive,
                                  style: TextStyle(
                                    color:
                                        Get.theme.primaryColor.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                    height: numUnreadMessages > 0 || chat.pinned
                                        ? 6
                                        : 26),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (numUnreadMessages > 0)
                                      _buildNumUnreadMessages(
                                          numUnreadMessages),
                                    if (chat.pinned) ...[
                                      SizedBox(width: 8),
                                      Icon(
                                        FluentIcons.pin_20_filled,
                                        size: 20,
                                        color: Color(0xFF606060),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(width: 4),
                          ],
                          onPressed: () => controller.tapChat(chat),
                          onLongPress: () => controller.toggleSelectChat(chat),
                        ),
                      );
                    },
                  );
                },
              ))
          .toList(),
    );
  }

  Widget _buildNumUnreadMessages(int numUnreadMessages) {
    return Container(
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Color(0xFF606060),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          numUnreadMessages.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
