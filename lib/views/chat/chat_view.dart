import 'package:discourse/controllers/message_selection.dart';
import 'package:discourse/controllers/message_sender.dart';
import 'package:discourse/models/db_objects/user_chat.dart';
import 'package:discourse/views/chat/widgets/message_draft_view.dart';
import 'package:discourse/views/chat/widgets/message_view.dart';
import 'package:discourse/widgets/opacity_feedback.dart';
import 'package:discourse/widgets/photo.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_controller.dart';

class ChatView extends StatelessWidget {
  final UserChat userChat;

  const ChatView({Key? key, required this.userChat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put<UserChat>(userChat); // current chat
    Get.put<MessageSenderController>(MessageSenderController());
    Get.put<MessageSelectionController>(MessageSelectionController());
    return GetBuilder<ChatController>(
      init: ChatController(userChat),
      builder: (controller) => Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
          child: Column(
            children: [
              Expanded(
                child: userChat is NonExistentChat
                    ? SizedBox()
                    : ListView.separated(
                        reverse: true,
                        itemCount: controller.messages.length,
                        itemBuilder: (context, i) {
                          final message = controller.messages[i];
                          return MessageView(message: message);
                        },
                        separatorBuilder: (context, i) {
                          if (controller.isPrivateChat) {
                            return SizedBox.shrink();
                          }
                          // final prevMessage =
                          //     controller.messages[i + 1]; // list is reversed
                          // final nextMessage = controller.messages[i];
                          // if (prevMessage.sender != nextMessage.sender &&
                          //     !prevMessage.fromMe) {
                          //   return Padding(
                          //     padding: const EdgeInsets.only(
                          //         left: 30, top: 20, bottom: 40),
                          //     child: _buildSenderDetails(
                          //         prevMessage.sender as Participant),
                          //   );
                          // }
                          return SizedBox(height: 10);
                        },
                      ),
              ),
              SizedBox(height: 28),
              MessageDraftView(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => PreferredSize(
        preferredSize: Size.fromHeight(76),
        child: SafeArea(
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Get.theme.primaryColorLight,
            child: Row(
              children: [
                OpacityFeedback(
                  child: Icon(FluentIcons.chevron_left_20_regular),
                  onPressed: () => Get.back(),
                ),
                SizedBox(width: 20),
                Expanded(child: _appBarContent()),
                GestureDetector(
                  child: Icon(FluentIcons.more_vertical_24_regular),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

  Widget _appBarContent() => Row(
        children: [
          PhotoView(
            photoUrl: userChat.photoUrl,
            placeholderIcon: userChat is UserPrivateChat
                ? FluentIcons.person_16_regular
                : FluentIcons.person_16_regular,
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userChat.title,
                  style: userChat.subtitle != null
                      ? TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
                      : TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                if (userChat.subtitle != null) SizedBox(height: 4),
                if (userChat.subtitle != null)
                  Text(
                    userChat.subtitle!,
                    style: TextStyle(
                      color: Get.theme.primaryColor.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
}
