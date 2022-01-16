import 'package:discourse/models/db_objects/message.dart';
import 'package:discourse/utils/show_group_chat_options.dart';
import 'package:discourse/views/groups/groups_controller.dart';
import 'package:discourse/widgets/floating_action_button.dart';
import 'package:discourse/widgets/list_tile.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsView extends StatelessWidget {
  const GroupsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupsController>(
      global: false,
      init: GroupsController(),
      builder: (controller) => Scaffold(
        floatingActionButton: MyFloatingActionButton(
          iconData: FluentIcons.add_20_filled,
          onPressed: controller.newGroup,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 44),
                Text(
                  'Friend groups',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 44),
                _buildGroupsList(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsList(GroupsController controller) => controller.loading
      ? SizedBox()
      : Column(
          children: controller.chats
              .map((chat) => StreamBuilder(
                    stream: controller.lastMessageStream(chat),
                    builder: (context, AsyncSnapshot<Message?> snapshot) {
                      String subtitle = '';
                      if (snapshot.hasData) {
                        final message = snapshot.data!;
                        final sender =
                            message.fromMe ? 'You' : message.sender.username;
                        subtitle = '$sender: ${message.text}';
                      }
                      return MyListTile(
                        title: chat.title,
                        subtitle: subtitle,
                        photoUrl: chat.photoUrl,
                        iconData: FluentIcons.person_16_regular,
                        suffixIcons: {
                          FluentIcons.more_vertical_20_regular: () =>
                              showGroupChatOptions(),
                        },
                        onPressed: () => controller.goToChat(chat),
                      );
                    },
                  ))
              .toList(),
        );
}
