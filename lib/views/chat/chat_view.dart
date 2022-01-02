import 'package:discourse/models/unsent_message.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:discourse/constants/palette.dart';
import 'package:discourse/models/chat_participant.dart';
import 'package:discourse/models/user_chat.dart';
import 'package:discourse/widgets/pressed_builder.dart';
import 'package:discourse/views/chat/dumb_widgets/participants_typing.dart';
import 'package:get/get.dart';

import 'chat_controller.dart';
import 'smart_widgets/message_view.dart';
import 'smart_widgets/message_field_view.dart';

class ChatView extends StatelessWidget {
  final UserChat userChat;

  const ChatView({Key? key, required this.userChat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: _builder);
  }

  Widget _builder(ChatController controller) {
    return Scaffold(
      appBar: controller.isSelectingMessages
          ? _buildMessageSelectionAppBar(controller) as PreferredSizeWidget
          : _buildAppBar(controller) as PreferredSizeWidget,
      body: Stack(
        children: [
          Positioned.fill(child: _buildMessagesList(controller)),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTypingIndicator(controller),
                    Spacer(),
                    if (controller.showGoToBottomArrow)
                      _buildScrollToBottomArrow(controller),
                  ],
                ),
                SizedBox(height: 18),
                if (!controller.isSelectingMessages) MessageFieldView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ChatController controller) => AppBar(
        title: PressedBuilder(
          onPressed: controller.goToChatDetails,
          builder: (pressed) => Opacity(
            opacity: pressed ? 0.8 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.userChat.title),
                if (controller.userChat.subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      controller.userChat.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [_buildPopupMenuButton(controller)],
      );

  Widget _buildMessageSelectionAppBar(ChatController controller) => AppBar(
        automaticallyImplyLeading: false,
        title: Text('${controller.numMessagesSelected} messages selected'),
        actions: [
          if (controller.canReplyToSelectedMessages)
            IconButton(
              icon: Icon(FluentIcons.arrow_reply_20_regular, size: 20),
              onPressed: controller.replyToSelectedMessages,
            ),
          if (controller.canDeleteSelectedMessages)
            IconButton(
              icon: Icon(FluentIcons.delete_20_regular, size: 20),
              onPressed: controller.deleteSelectedMessages,
            ),
          IconButton(
            icon: Icon(FluentIcons.dismiss_20_regular, size: 20),
            onPressed: controller.cancelMessageSelection,
          ),
        ],
      );

  Widget _buildPopupMenuButton(ChatController controller) {
    final actions = {
      'Export chat': controller.exportChat,
      'Leave chat': controller.leaveChat,
    };
    return PopupMenuButton(
      onSelected: (value) {
        actions[value]!();
      },
      itemBuilder: (BuildContext context) {
        return actions
            .map((title, method) => MapEntry(
                  title,
                  PopupMenuItem(value: title, child: Text(title)),
                ))
            .values
            .toList();
      },
    );
  }

  Widget _buildMessagesList(ChatController controller) => ListView.separated(
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 100),
        controller: controller.scrollController,
        itemCount: controller.messages.length,
        itemBuilder: (context, i) {
          final message = controller.messages[i];
          return MessageView(
            // TODO: FIXME: how would this work
            key: message is UnsentMessage
                ? controller.messageKey(message.id)
                : null,
            message: message,
            isSent: true,
          );
        },
        separatorBuilder: (context, i) {
          if (controller.isPrivateChat) {
            return SizedBox.shrink();
          }
          final prevMessage = controller.messages[i + 1]; // list is reversed
          final nextMessage = controller.messages[i];
          if (prevMessage.sender != nextMessage.sender && !prevMessage.fromMe) {
            return Padding(
              padding: const EdgeInsets.only(left: 30, top: 20, bottom: 40),
              child: _buildSenderDetails(prevMessage.sender as Participant),
            );
          }
          return SizedBox(height: 10);
        },
      );

  Widget _buildSenderDetails(Participant sender) => Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: sender.color.withOpacity(1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: 14),
          Text(
            sender.user.username,
            style: TextStyle(
              color: sender.color.withOpacity(1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _buildTypingIndicator(ChatController controller) =>
      StreamBuilder<String?>(
        stream: controller.typingTextStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();
          return TypingIndicator(text: snapshot.data!);
        },
      );

  Widget _buildScrollToBottomArrow(ChatController controller) =>
      GestureDetector(
        onTap: controller.scrollToBottom,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Palette.accent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Icon(
            FluentIcons.arrow_down_20_regular,
            size: 16,
            color: Colors.white,
          ),
        ),
      );
}
